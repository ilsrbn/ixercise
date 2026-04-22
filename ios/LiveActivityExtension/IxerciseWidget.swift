import SwiftUI
import WidgetKit

struct IxerciseWidgetEntry: TimelineEntry {
  let date: Date
}

struct IxerciseWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> IxerciseWidgetEntry {
    IxerciseWidgetEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (IxerciseWidgetEntry) -> Void) {
    completion(IxerciseWidgetEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<IxerciseWidgetEntry>) -> Void) {
    completion(
      Timeline(
        entries: [IxerciseWidgetEntry(date: Date())],
        policy: .never
      )
    )
  }
}

struct IxerciseWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "IxerciseWidget",
      provider: IxerciseWidgetProvider()
    ) { _ in
      VStack(alignment: .leading, spacing: 6) {
        Text("Ixercise")
          .font(.headline.weight(.bold))
        Text("Ready to train")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding()
      .background(Color(.systemBackground))
    }
    .configurationDisplayName("Ixercise")
    .description("Quick workout status.")
    .supportedFamilies([.systemSmall])
  }
}
