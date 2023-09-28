//
//  AQIWidget.swift
//  AQIWidget
//
//  Created by ZHOU QUAN on 2020/12/14.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AQIEntry {
        AQIEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AQIEntry) -> ()) {
        let entry = AQIEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Create a timeline entry for "now."
        let date = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        getAQI { (entry, error) in
            let entry = entry
            let timeline = Timeline(entries:[entry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct AQIEntry: TimelineEntry {
    var date: Date
    var num: String
    var red: Double
    var green: Double
    var blue: Double
    var textColor: Color
    
    init(num: String = "500", red: Double = 1, green: Double = 1, blue: Double = 1, textColor: Color = .black){
        self.date = Date()
        self.num = num
        self.red = red
        self.green = green
        self.blue = blue
        self.textColor = textColor
    }
}

extension View {
    func expandable() -> some View {
        ZStack {
            Color.clear
            self
        }
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct AQIWidgetView : View {
    var entry: Provider.Entry
    var body: some View {
        Text(entry.num)
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            .font(.system(size: 65))
            .foregroundColor(entry.textColor)
            .expandable()
            .widgetBackground(Color(Color.RGBColorSpace.sRGB,
                                    red: entry.red,
                                    green: entry.green,
                                    blue: entry.blue,
                                    opacity: 1))
            .background(Color(Color.RGBColorSpace.sRGB,
                              red: entry.red,
                              green: entry.green,
                              blue: entry.blue,
                              opacity: 1))
    }
}

@main
struct AQIWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "AQIWidget", provider: Provider()) { entry in
            AQIWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct AQIWidget_Previews: PreviewProvider {
    static var previews: some View {
        AQIWidgetView(entry: AQIEntry())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

func getAQI(completion:@escaping (AQIEntry, Error?) -> Void) {
    let url = URL(string: "https://aqicn.org/city/beijing/cn/")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            let entry = AQIEntry()
            completion(entry, error)
        }
        if let data = data {
            let string = String(data: data, encoding: .utf8)!
            let matched = matches(for: "<div class='aqivalue' id='aqiwgtvalue'[^<]*</div>", in: string, index: 0)
            let hex = matches(for: "background-color: #([^;]+)", in: matched, index: 1)
            let scanner = Scanner(string: hex)
            var rgb: UInt64 = 0
            scanner.scanHexInt64(&rgb)
            let red = Double((rgb&0xFF0000)>>16)/255.0
            let green = Double((rgb&0xFF00)>>8)/255.0
            let blue = Double((rgb&0xFF))/255.0
            let num = matches(for: ">([0-9]+)<", in: matched, index: 1)
            var textColor: Color
            if red == 1 {
                textColor = .black
            } else {
                textColor = .white
            }
            let entry = AQIEntry(num: num, red: red, green: green, blue: blue, textColor: textColor)
            completion(entry, error)
        }
    }
    task.resume()
}

func matches(for pattern: String, in text: String, index: Int) -> String {
    var result: String?
    let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    if let match = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
        if let range = Range(match.range(at: index), in: text) {
            result = String(text[range])
        }
    }
    return result!
}
