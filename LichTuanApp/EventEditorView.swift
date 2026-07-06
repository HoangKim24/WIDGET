import SwiftUI

/// Màn hình thêm/sửa sự kiện. UI này chỉ lo nhập liệu, còn lưu dữ liệu do ContentView quyết định.
struct EventEditorView: View {
    private let existingEvent: CalendarEvent?
    private let onSave: (CalendarEvent) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var selectedCategory: EventCategory

    init(event: CalendarEvent?, onSave: @escaping (CalendarEvent) -> Void) {
        self.existingEvent = event
        self.onSave = onSave
        _title = State(initialValue: event?.title ?? "")
        _startDate = State(initialValue: event?.startDate ?? Date())
        _endDate = State(initialValue: event?.endDate ?? Date().addingTimeInterval(60 * 60))
        _isAllDay = State(initialValue: event?.isAllDay ?? false)
        _selectedCategory = State(initialValue: event?.category ?? .other)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    TextField("Event title", text: $title)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(EventCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.symbolName)
                                .tag(category)
                        }
                    }
                    Toggle("All day", isOn: $isAllDay)
                }

                Section("Timing") {
                    DatePicker("Start", selection: $startDate)
                    DatePicker("End", selection: $endDate)
                }

                Section("Preview") {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.gradient(for: selectedCategory))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: selectedCategory.symbolName)
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedCategory.displayName)
                                .font(.headline)
                            Text("Category icon and color are driven by assets.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(existingEvent == nil ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && endDate >= startDate
    }

    private func saveEvent() {
        let savedEvent = CalendarEvent(
            id: existingEvent?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            category: selectedCategory,
            isAllDay: isAllDay
        )

        onSave(savedEvent)
        dismiss()
    }
}

#Preview {
    EventEditorView(event: nil) { _ in }
}
