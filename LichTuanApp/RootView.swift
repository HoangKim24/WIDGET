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
                        ContentUnavailableView {
                            Label("No events yet", systemImage: "calendar.badge.plus")
                        } description: {
                            Text("Add your first event so the widget can read it from the App Group.")
                        } actions: {
                            Button("Add Event") {
                                editorContext = .add
                            }
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
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [AppColors.primary.opacity(0.08), AppColors.accent.opacity(0.08), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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
                        .font(.title.bold())
                    Text("Cùng một bảng màu, icon và dữ liệu cho app, widget, và screenshot CI.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent))
                    .frame(width: 72, height: 72)
                    .overlay {
                        Image(systemName: nextEvent?.category.symbolName ?? "calendar")
                            .foregroundStyle(.white)
                            .font(.title2.bold())
                    }
            }

            HStack(spacing: 12) {
                StatChip(title: "Events", value: "\(totalEvents)", icon: "calendar.badge.plus")
                StatChip(title: "Next", value: nextEvent?.category.displayName ?? "None", icon: nextEvent?.category.symbolName ?? "circle")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.primary.opacity(0.18), lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.65))
        )
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.gradient(for: event.category))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: event.category.symbolName)
                        .foregroundStyle(.white)
                        .font(.headline)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(event.category.displayName, systemImage: event.category.symbolName)
                        .font(.caption)
                        .foregroundStyle(event.category.color)
                        .labelStyle(.titleAndIcon)

                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
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

