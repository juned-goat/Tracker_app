import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Daily Progress") {
                    if let progress = viewModel.progress {
                        LabeledContent("Calories", value: "\(progress.totalMacros.calories)")
                        LabeledContent("Protein", value: formattedGrams(progress.totalMacros.proteinGrams))
                        LabeledContent("Carbs", value: formattedGrams(progress.totalMacros.carbohydrateGrams))
                        LabeledContent("Fat", value: formattedGrams(progress.totalMacros.fatGrams))
                    } else {
                        Text("No meals logged today.")
                    }
                }

                Section("Meals") {
                    ForEach(viewModel.progress?.meals ?? []) { meal in
                        VStack(alignment: .leading) {
                            Text(meal.name)
                            Text("\(meal.macros.calories) calories")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Add Sample Meal") {
                        Task { await viewModel.addSampleMeal() }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                Button("Sign Out") {
                    viewModel.signOut()
                }
            }
            .task {
                await viewModel.loadToday()
            }
        }
    }

    private func formattedGrams(_ value: Double) -> String {
        String(format: "%.1f g", value)
    }
}
