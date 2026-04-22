import ActivityKit
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.2, *)
struct IxerciseLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: IxerciseWorkoutActivityAttributes.self) { context in
      IxerciseLockScreenView(context: context)
        .activityBackgroundTint(Color.black)
        .activitySystemActionForegroundColor(Color.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            Text(context.state.phase.uppercased())
              .font(.caption2.weight(.bold))
              .foregroundStyle(.secondary)
            Text(context.state.title)
              .font(.headline.weight(.bold))
              .lineLimit(1)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          IxerciseTimeView(state: context.state)
            .font(.title3.monospacedDigit().weight(.bold))
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            Text(context.state.subtitle)
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .lineLimit(1)
            ProgressView(value: context.state.progress)
              .tint(Color(red: 0.88, green: 0.11, blue: 0.18))
          }
        }
      } compactLeading: {
        Text(context.state.phase == "Rest" ? "Rest" : "Go")
          .font(.caption.weight(.bold))
      } compactTrailing: {
        IxerciseTimeView(state: context.state)
          .font(.caption.monospacedDigit().weight(.bold))
      } minimal: {
        Image(systemName: context.state.phase == "Rest" ? "pause.fill" : "figure.strengthtraining.traditional")
      }
      .widgetURL(URL(string: "ixercise://session/\(context.attributes.sessionId)"))
      .keylineTint(Color(red: 0.88, green: 0.11, blue: 0.18))
    }
  }
}

@available(iOSApplicationExtension 16.2, *)
private struct IxerciseLockScreenView: View {
  let context: ActivityViewContext<IxerciseWorkoutActivityAttributes>

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(context.attributes.planName)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
          Text(context.state.title)
            .font(.title2.weight(.bold))
            .lineLimit(1)
        }
        Spacer()
        IxerciseTimeView(state: context.state)
          .font(.title.monospacedDigit().weight(.black))
      }

      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(context.state.phase)
            .font(.subheadline.weight(.bold))
          Spacer()
          Text(context.state.subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        ProgressView(value: context.state.progress)
          .tint(Color(red: 0.88, green: 0.11, blue: 0.18))
      }
    }
    .padding(20)
  }
}

@available(iOSApplicationExtension 16.2, *)
private struct IxerciseTimeView: View {
  let state: IxerciseWorkoutActivityAttributes.ContentState

  var body: some View {
    if state.isPaused {
      Text("Paused")
    } else if let remainingSeconds = state.remainingSeconds {
      Text(Self.format(seconds: remainingSeconds))
    } else {
      Text("--")
    }
  }

  private static func format(seconds: Int) -> String {
    let safeSeconds = max(0, seconds)
    return String(format: "%02d:%02d", safeSeconds / 60, safeSeconds % 60)
  }
}
