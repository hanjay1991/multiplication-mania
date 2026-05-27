//
//  ContentView.swift
//  MultiplicationMania
//
//  Created by Jay Hanley on 5/25/26.
//

import Combine
import SwiftUI

class GameSettings: ObservableObject {
    
    @Published var difficulty: String = "Easy"
    @Published var timesTables: Int = 2
    @Published var numberOfProblems: Int = 10
    @Published var anythingAndEverything: Bool = false
    
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameSettings: GameSettings
    
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Hmm...how hard?")
                    .font(.custom("ArialRoundedMTBold",size: 23))
                    .listRowSeparator(.hidden)
                HStack {
                    Button {
                        gameSettings.difficulty = "Easy"
                    } label: {
                        Text("Easy")
                            .font(.custom("ArialRoundedMTBold",size: 21))
                            .padding()
                            .background(.green)
                            .clipShape(Capsule())
                            .shadow(radius:5)
                            .opacity(gameSettings.difficulty == "Easy" ? 1.0 : 0.25)
                            .scaleEffect(gameSettings.difficulty == "Easy" ? 1 : 0.6)
                    }
                    .buttonStyle(.plain)
                    Button {
                        gameSettings.difficulty = "Medium"
                    } label: {
                        Text("Medium")
                            .font(.custom("ArialRoundedMTBold",size: 21))
                            .padding()
                            .background(.yellow)
                            .clipShape(Capsule())
                            .shadow(radius:5)
                            .opacity(gameSettings.difficulty == "Medium" ? 1.0 : 0.25)
                            .scaleEffect(gameSettings.difficulty == "Medium" ? 1 : 0.6)
                    }
                    .buttonStyle(.plain)
                    Button {
                        gameSettings.difficulty = "Hard"
                    } label: {
                        Text("Hard")
                            .font(.custom("ArialRoundedMTBold",size: 23))
                            .padding()
                            .background(.red)
                            .clipShape(Capsule())
                            .shadow(radius:5)
                            .opacity(gameSettings.difficulty == "Hard" ? 1.0 : 0.25)
                            .scaleEffect(gameSettings.difficulty == "Hard" ? 1 : 0.6)
                    }
                    .buttonStyle(.plain)
                }
                Text("What times tables (up to 12)?")
                    .font(.custom("ArialRoundedMTBold",size: 23))
                    .listRowSeparator(.hidden)
                Text("I want...\(gameSettings.timesTables)'s")
                    .font(.custom("ArialRoundedMTBold",size: 21))
                    .listRowSeparator(.hidden)
                HStack {
                    Button {
                        if gameSettings.timesTables > 1 {
                            gameSettings.timesTables -= 1
                        } else {
                            gameSettings.timesTables = 1
                        }
                    } label: {
                        Text("-")
                            .font(.custom("ArialRoundedMTBold",size: 45))
                            .padding(40)
                            .background(.red)
                            .clipShape(Circle())
                            .shadow(radius:5)
                            .opacity(gameSettings.timesTables == 1 ? 0.25: 1.0)
                    }
                    .buttonStyle(.plain)
                    Button {
                        if gameSettings.timesTables < 12 {
                            gameSettings.timesTables += 1
                        } else {
                            gameSettings.timesTables = 12
                        }
                    } label: {
                        Text("+")
                            .font(.custom("ArialRoundedMTBold",size: 35))
                            .padding(40)
                            .background(.green)
                            .clipShape(Circle())
                            .shadow(radius:5)
                            .opacity(gameSettings.timesTables == 12 ? 0.25: 1.0)
                    }
                    .buttonStyle(.plain)
                }
                Text("How many problems?")
                    .font(.custom("ArialRoundedMTBold",size: 23))
                    .listRowSeparator(.hidden)
                HStack {
                    Button {
                        gameSettings.numberOfProblems = 5
                    } label: {
                        Text("5")
                            .font(.custom("ArialRoundedMTBold",size: 23))
                            .padding(40)
                            .background(.green)
                            .clipShape(Circle())
                            .shadow(radius:5)
                            .opacity(gameSettings.numberOfProblems == 5 ? 1.0: 0.25)
                    }
                    .buttonStyle(.plain)
                    Button {
                        gameSettings.numberOfProblems = 10
                    } label: {
                        Text("10")
                            .font(.custom("ArialRoundedMTBold",size: 23))
                            .padding(35)
                            .background(.yellow)
                            .clipShape(Circle())
                            .shadow(radius:5)
                            .opacity(gameSettings.numberOfProblems == 10 ? 1.0: 0.25)
                    }
                    .buttonStyle(.plain)
                    Button {
                        gameSettings.numberOfProblems = 20
                    } label: {
                        Text("20")
                            .font(.custom("ArialRoundedMTBold",size: 23))
                            .padding(35)
                            .background(.red)
                            .clipShape(Circle())
                            .shadow(radius:5)
                            .opacity(gameSettings.numberOfProblems == 20 ? 1.0: 0.25)
                    }
                    .buttonStyle(.plain)
                    Text("")
                        .navigationTitle("Settings")
                        .navigationBarItems(trailing: Button("Done") {
                            dismiss()
                        })
                        .listRowSeparator(.hidden)
                }
            }
        }
    }
}

struct GameView: View {
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject var gameSettings: GameSettings
    
    @State private var showSettings = false
    @State private var gameActive = false
    @State private var alertTrigger = false
    @State private var gameOver: Bool = false
    @State private var ranOutOfTime: Bool = false
    
    @State private var problemNumber: Int = 1
    @State private var firstNumber = 2
    @State private var secondNumber = 0
    @State private var userAnswer: Int? = nil
    
    @State private var correctTitle = ""
    @State private var correctAnswer: Bool? = nil
    
    @State private var currentProblem = ""
    @State private var numProblemsCompleted = 0
    @State private var score: Int = 0
    
    let animals: Array = ["elephant","giraffe","hippo","monkey","panda","parrot","penguin", "pig", "rabbit","snake","elephant","giraffe","hippo","monkey","panda","parrot","penguin", "pig", "rabbit","snake"]
    @State private var animalsLit: [Bool] = Array(repeating: false, count: 20)
    
    @State private var funTimer: Double = 0.0
    
    @FocusState private var textFieldFocus: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
            
                RadialGradient(stops: [
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45),location:0.3),
                    .init(color:Color(red:0.76, green: 0.15, blue: 0.26),location: 0.3),
                ], center: .top, startRadius: 200, endRadius:400)
                .ignoresSafeArea()
            
                VStack {
                    Spacer()
                    VStack {
                        Text("Multiplication")
                            .font(.custom("ArialRoundedMTBold",size: 40))
                        Text("Mania")
                            .font(.custom("ArialRoundedMTBold",size: 40))
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("Problem \(problemNumber):")
                        .offset(y:15)
                        .font(.custom("ArialRoundedMTBold",size: 30))
                    Text(currentProblem)
                        .offset(y:15)
                        .font(.custom("ArialRoundedMTBold",size: 30))
                    Spacer()
                    TextField("?",value: $userAnswer, format: .number)
                        .keyboardType(.numberPad)
                        .focused($textFieldFocus)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                
                                Button ("Go!") {
                                    checkAnswer(answer: userAnswer ?? 0)
                                    textFieldFocus = false
                                }
                            }
                        }
                        .font(.custom("ArialRoundedMTBold",size: 30))
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .frame(width:150, height: 80)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.black, lineWidth: 3))
                        .padding(.horizontal, 200)
                        .padding(.vertical, 20)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    VStack {
                        ForEach(0..<(gameSettings.numberOfProblems/5), id: \.self) { row in
                            HStack {
                                ForEach(0..<5, id: \.self) { col in
                                    Image(animals[row*5+col])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:60,height:60)
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                        .opacity(animalsLit[row*5+col] ? 1.0 : 0.2)
                                }
                            }
                        }
                    }
                    if gameSettings.difficulty == "Hard" {
                        Text("\(funTimer, specifier: "%.0f")")
                            .font(.title)
                    }
                    Spacer()
                    Spacer()
                    }
                    .alert(correctTitle, isPresented: $alertTrigger) {
                        Button("Ok", action: problemGenerator)
                    }
                    .alert("You did it! Let's play again!",isPresented: $gameOver) {
                        Button("Ok",action: restart)
                    } message: {
                        Text("Your score is \(score)")
                    }
                    .alert("Oh no! Out of time!", isPresented: $ranOutOfTime) {
                        Button("Ok") {
                            gameActive = false
                            restart()
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            startGame()
                        }
                    }
                    .onReceive(timer) { _ in
                        guard !gameOver && gameActive && gameSettings.difficulty == "Hard" else { return }
                        if gameActive && funTimer > 0 {
                            funTimer -= 0.01
                        } else if numProblemsCompleted < gameSettings.numberOfProblems && funTimer <= 0 {
                            ranOutOfTime = true
                        }
                    }
                    .toolbar {
                        Button("Settings") {
                            showSettings = true
                        }
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                    .onChange(of: gameSettings.difficulty) {
                        restart()
                    }
                    .onChange(of: gameSettings.timesTables) {
                        restart()
                    }
                    .onChange(of: gameSettings.numberOfProblems) {
                        restart()
                    }
            }
        }
    }
    func startGame() {
        problemGenerator()
        setTimer()
        gameActive = true
    }
    func problemGenerator() {
        if gameSettings.difficulty == "Easy" {
            firstNumber = gameSettings.timesTables
            secondNumber = Int.random(in: 1...12)
            currentProblem = "\(firstNumber) x \(secondNumber)"
        } else if gameSettings.difficulty == "Medium" || gameSettings.difficulty == "Hard" {
            let coinFlip = Int.random(in: 0...1)
            if coinFlip == 0 {
                firstNumber = gameSettings.timesTables
                secondNumber = Int.random(in: 1...12)
                currentProblem = "\(firstNumber) x \(secondNumber)"
            } else {
                firstNumber = Int.random(in: 1...12)
                secondNumber = gameSettings.timesTables
                currentProblem = "\(firstNumber) x \(secondNumber)"
            }
        }
    }
    func checkAnswer(answer: Int) {
        numProblemsCompleted += 1
        if userAnswer == firstNumber * secondNumber {
            score += 1
            correctTitle = "Yay you got it!"
            alertTrigger = true
            
            let animalLitArray = animalsLit.indices.filter {
                $0 < gameSettings.numberOfProblems && !animalsLit[$0]
            }
            
            
            if let randomAnimalLit = animalLitArray.randomElement() {
                animalsLit[randomAnimalLit] = true
            }
            
        } else {
            score -= 1
            correctTitle = "Oops, that's not right!"
            alertTrigger = true
            
            let animalLitArray = animalsLit.indices.filter {
                $0 < gameSettings.numberOfProblems && animalsLit[$0]
            }
            if let randomAnimalLit = animalLitArray.randomElement() {
                animalsLit[randomAnimalLit] = false
            }
        }
        userAnswer = nil
        if problemNumber >= gameSettings.numberOfProblems {
            gameOver = true
            
        } else {
            problemNumber += 1
        }
    }
    func setTimer() {
        guard gameSettings.difficulty == "Hard" else {
            return
        }
        if gameSettings.numberOfProblems == 5 {
            funTimer = 30.0
        } else if gameSettings.numberOfProblems == 10 {
            funTimer = 60.0
        } else {
            funTimer = 120.0
        }
    }
    func restart() {
        gameActive = false
        animalsLit = [Bool](repeating: false, count: animals.count)
        numProblemsCompleted = 0
        score = 0
        funTimer = 0
        problemNumber = 1
        problemGenerator()
        setTimer()
        gameActive = true
    }
}

#Preview {
    GameView()
        .environmentObject(GameSettings())
}
