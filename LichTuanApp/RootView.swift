import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EventListViewModel()
    @State private var editorContext: EditorContext?
    @State private var showAppIconConcepts = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HeroCardView(totalEvents: viewModel.events.count, nextEvent: viewModel.events.first)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("Upcoming") {
                    if viewModel.events.isEmpty {
                        EmptyEventsCard {
                            editorContext = .add
                        }
                    } else {
                        ForEach(viewModel.events) { event in
                            EventRow(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editorContext = .edit(event)
                                }
                        }
                        .onDelete(perform: viewModel.delete(at:))
                    }
                }

                Section("Visuals") {
                    Button {
                        showAppIconConcepts = true
                    } label: {
                        Label("Preview App Icon Concepts", systemImage: "paintpalette.fill")
                    }
                }
            }
            .navigationTitle("Lich Tuan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Refresh") {
                        viewModel.load()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorContext = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        viewModel.clearAll()
                    } label: {
                        Text("Clear All")
                    }
                    .disabled(viewModel.events.isEmpty)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .bottomBar)
            .sheet(item: $editorContext) { context in
                switch context {
                case .add:
                    EventEditorView(event: nil) { newEvent in
                        viewModel.add(newEvent)
                        editorContext = nil
                    }
                case .edit(let event):
                    EventEditorView(event: event) { updatedEvent in
                        viewModel.update(updatedEvent)
                        editorContext = nil
                    }
                }
            }
            .sheet(isPresented: $showAppIconConcepts) {
                AppIconConceptsView()
            }
            .onAppear {
                viewModel.load()
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [AppColors.primary.opacity(0.14), AppColors.accent.opacity(0.10), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(AppColors.accent.opacity(0.16))
                        .frame(width: 240, height: 240)
                        .blur(radius: 40)
                        .offset(x: 150, y: -220)

                    Circle()
                        .fill(AppColors.primary.opacity(0.16))
                        .frame(width: 200, height: 200)
                        .blur(radius: 36)
                        .offset(x: -130, y: 420)
                }
                .ignoresSafeArea()
            )
        }
    }
}

private struct HeroCardView: View {
    let totalEvents: Int
    let nextEvent: CalendarEvent?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lich Tuan")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Một bảng lịch tuần có màu, icon và widget đồng bộ.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent))
                        .frame(width: 84, height: 84)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.12))
                        .frame(width: 58, height: 58)
                        .overlay {
                            Image(systemName: nextEvent?.category.symbolName ?? "calendar")
                                .foregroundStyle(.white)
                                .font(.title3.weight(.semibold))
                        }
                }
                .shadow(color: AppColors.accent.opacity(0.18), radius: 18, y: 10)
                
            }

            HStack(spacing: 10) {
                StatChip(title: "Events", value: "\(totalEvents)", icon: "calendar.badge.plus")
                StatChip(title: "Next", value: nextEvent?.category.displayName ?? "None", icon: nextEvent?.category.symbolName ?? "circle")
            }

            HStack(spacing: 8) {
                Label("App + Widget synced", systemImage: "link")
                Spacer()
                Text(Date.now, style: .date)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [AppColors.primary.opacity(0.24), AppColors.accent.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.primary.opacity(0.08), radius: 20, y: 8)
        .padding(.vertical, 4)
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.accent.opacity(0.14))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .foregroundStyle(AppColors.accent)
                    .font(.caption.weight(.semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.gradient(for: event.category))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: event.category.symbolName)
                        .foregroundStyle(.white)
                        .font(.headline.weight(.semibold))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    CapsuleLabel(text: event.category.displayName, symbol: event.category.symbolName, tint: event.category.color)

                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
        .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
        .listRowBackground(Color.clear)
    }

    private var detailText: String {
        if event.isAllDay {
            return "All day"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }
}

private struct CapsuleLabel: View {
    let text: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }
}

private struct EmptyEventsCard: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent))
                        .frame(width: 56, height: 56)

                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.white)
                        .font(.title3.weight(.semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("No events yet")
                        .font(.headline)
                    Text("Add your first event so the widget can reflect your week and screenshot previews look alive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(action: onAdd) {
                Label("Add Event", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(AppColors.primary.opacity(0.18), lineWidth: 1)
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

private enum EditorContext: Identifiable {
    case add
    case edit(CalendarEvent)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let event):
            return event.id.uuidString
        }
    }
}

#Preview {
    ContentView()
}

