import SwiftUI
import MLXModelManager
import MarkdownUI

struct ContentView: View {
    @StateObject var Phi4Manager = ModelManager(modelPath: "mlx-community/phi-4-4bit")
    
    @State var prompt = "create a small table on the pros and cons of using a local llm.?"
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Top controls: progress indicators
            HStack {
                Spacer()
                
                if Phi4Manager.isLoading {
                    VStack {
                        ProgressView(
                            value: Double(Phi4Manager.progressPercent),
                            total: 100
                        ) {
                            Text("Downloading Model...")
                        }
                        .frame(maxWidth: 200)
                        
                        Text("\(Phi4Manager.progressPercent)%")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
            }
            
            // Scrollable output (Markdown only)
            ScrollView(.vertical) {
                ScrollViewReader { scrollProxy in
                    Markdown(Phi4Manager.output)
                        .textSelection(.enabled)
                        .onChange(of: Phi4Manager.output) { _, _ in
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    
                    // "Bottom" spacer
                    Spacer()
                        .frame(width: 1, height: 1)
                        .id("bottom")
                }
            }
            
            // Prompt input + "Answer Prompt" button
            HStack {
                TextField("prompt", text: $prompt)
                    .onSubmit { answerPrompt() }
                    .disabled(Phi4Manager.isGenerating || Phi4Manager.isLoading)
                    .textFieldStyle(.roundedBorder)
                
                Button("Answer Prompt") {
                    answerPrompt()
                }
                .disabled(Phi4Manager.isGenerating || Phi4Manager.isLoading)
            }
        }
        .padding()
        .task {
            // Optionally pre-load the model on launch
            do {
                try await Phi4Manager.loadModel()
            } catch {
                print("Failed to load model: \(error)")
            }
        }
    }
    
    /// Trigger text generation using the current prompt
    private func answerPrompt() {
        Task {
            await Phi4Manager.generate(prompt: prompt)
        }
    }
}

#Preview {
    ContentView()
}

