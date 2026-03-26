//
//  HomeView.swift
//  PathwaysInsideProcessor
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            VStack(spacing:24){
                Text("Pathways: Inside the Processor")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                NavigationLink("Explore Datapath") {
                    Text("DatapathView()")
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink("Take Quiz") {
                    Text("QuizView()")
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
        }
    }
}
