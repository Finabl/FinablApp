//
//  GoalSummaryView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 2/8/25.
//

import SwiftUI

struct GoalSummaryView: View {
    @Binding var goals: [Goal] // ✅ Reference to the goals array
    var goal: Goal
    var userEmail: String
    var deleteGoal: (String) -> Void
    var markTaskComplete: (String, Int) -> Void
    @Environment(\.presentationMode) var presentationMode // 🔙 To navigate back

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(goal.title)
                .font(.title)
                .bold()
                .padding(.top)

            // 🔥 Progress Bar
            ProgressView(value: Double(goal.progress) / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .padding(.horizontal)

            // 🔥 Task List
            List {
                ForEach(goal.goaltasks.indices, id: \.self) { taskIndex in
                    HStack {
                        Text(goal.goaltasks[taskIndex].name)
                            .strikethrough(goal.goaltasks[taskIndex].completed, color: .gray)
                            .foregroundColor(goal.goaltasks[taskIndex].completed ? .gray : .black)

                        Spacer()

                        Button(action: {
                            markTaskComplete(goal.id, taskIndex)
                        }) {
                            Text(goal.goaltasks[taskIndex].completed ? "✔" : "Mark Complete")
                        }
                        .disabled(goal.goaltasks[taskIndex].completed)
                        .foregroundColor(goal.goaltasks[taskIndex].completed ? .gray : .blue)
                    }
                }
            }

            Spacer()

            // 🔥 Delete Goal Button
            Button(action: {
                deleteGoal(goal.id)
                presentationMode.wrappedValue.dismiss() // 🔙 Navigate back
            }) {
                Text("Delete Goal")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Goal Details")
    }
}

/*
#Preview {
    GoalSummaryView(goals: Binding<[Goal]>, goal: Goal, userEmail: String, deleteGoal: (String) -> Void, markTaskComplete: (String, Int) -> Void)
}
*/
