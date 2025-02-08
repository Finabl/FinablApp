//
//  IdeographView.swift
//  Finabl
//
//  Created by Mehdi Hussain on 2/8/25.
//

import SwiftUI

struct IdeographView: View {
    let ticker: String
    @State private var categories: [String: Category] = [:]
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @GestureState private var magnifyBy: CGFloat = 1.0
    @State private var position: CGSize = .zero
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("\(ticker) Ideograph")
                    .font(Font.custom("Anuphan-Medium", size: 18))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    // Settings or options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            ZStack {
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                } else {
                    GeometryReader { geometry in
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            VStack {
                                Text(ticker)
                                    .font(.title)
                                    .bold()
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                                    .offset(y: -40)
                                
                                Rectangle()
                                    .frame(width: 2, height: 40)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 40) {
                                    ForEach(categories.keys.sorted(), id: \..self) { category in
                                        VStack {
                                            CategoryView(name: category, data: categories[category]!)
                                            if let subcategories = categories[category]?.subcategories {
                                                ForEach(subcategories.keys.sorted(), id: \..self) { subcategory in
                                                    VStack {
                                                        Rectangle()
                                                            .frame(width: 2, height: 20)
                                                            .foregroundColor(.gray)
                                                        Text(subcategory)
                                                            .font(.subheadline)
                                                            .bold()
                                                        
                                                        VStack(alignment: .leading, spacing: 5) {
                                                            ForEach(subcategories[subcategory]!, id: \..ticker) { company in
                                                                Text("• \(company.ticker)")
                                                                    .font(.body)
                                                                    .padding(.horizontal)
                                                            }
                                                        }
                                                        .padding()
                                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            .scaleEffect(magnifyBy)
                            .offset(position)
                            .gesture(
                                MagnificationGesture()
                                    .updating($magnifyBy) { value, state, _ in
                                        state = value
                                    }
                                    .simultaneously(with:
                                        DragGesture()
                                            .onChanged { value in
                                                position.width += value.translation.width
                                                position.height += value.translation.height
                                            }
                                    )
                            )
                        }
                    }
                    
                }
                
                
            }

        }
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: "https://app.finabl.org/api/ideograph?ticker=\(ticker)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([String: Category].self, from: data)
                    DispatchQueue.main.async {
                        categories = decodedData
                        isLoading = false
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

struct CategoryView: View {
    let name: String
    let data: Category
    
    var body: some View {
        VStack {
            Text(name)
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(data.companies, id: \..ticker) { company in
                    Text("• \(company.ticker)")
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
            
            if let subcategories = data.subcategories {
                VStack(spacing: 10) {
                    ForEach(subcategories.keys.sorted(), id: \..self) { subcategory in
                        VStack {
                            Rectangle()
                                .frame(width: 2, height: 20)
                                .foregroundColor(.gray)
                            Text(subcategory)
                                .font(.subheadline)
                                .bold()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(subcategories[subcategory]!, id: \..ticker) { company in
                                    Text("• \(company.ticker)")
                                        .font(.body)
                                        .padding(.horizontal)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                        }
                    }
                }
            }
        }
    }
}

struct Category: Codable {
    let companies: [Company]
    let subcategories: [String: [Company]]?
}

struct Company: Codable {
    let ticker: String
    let description: String
}



#Preview {
    IdeographView(ticker: "AAPL")
}
