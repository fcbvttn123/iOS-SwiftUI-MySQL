import SwiftUI

struct InstructionView: View {
    // State Variables
    var startToStop1ToStop2ToDestination : [RouteSteps]?
    var startToStop1 : [RouteSteps]?
    var stop1ToStop2 : [RouteSteps]?
    var stop1Text : String = "Stop 1"
    var stop2Text : String = "Stop 2"
    var destinationText : String = "Destination"    
    @State var pickerViewValue = 0
    // Screen
    var body: some View {
        ZStack {
            Image("images")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Picker(selection: $pickerViewValue, label: Text("Difficulty")) {
                    Text("Whole Route").tag(0)
                    Text("My House to \(stop1Text)").tag(1)
                    Text("\(stop1Text) to \(stop2Text)").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .padding(.horizontal)
                if pickerViewValue == 0 {
                    Text("My house to \(stop1Text)")
                        .font(.headline)
                        .foregroundColor(.white)
                    List(startToStop1ToStop2ToDestination ?? []) { obj in
                        Text(obj.step)
                        .padding(10)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    Text("\(stop1Text) to \(stop2Text)")
                        .font(.headline)
                        .foregroundColor(.white)
                    List(startToStop1 ?? []) { obj in
                        Text(obj.step)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    Text("\(stop2Text) to \(destinationText)")
                        .font(.headline)
                        .foregroundColor(.white)
                    List(stop1ToStop2 ?? []) { obj in
                        Text(obj.step)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                } else if pickerViewValue == 1 {
                    Text("My house to \(stop1Text)")
                        .font(.headline)
                        .foregroundColor(.white)
                    List(startToStop1ToStop2ToDestination ?? []) { obj in
                        Text(obj.step)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
                } else if pickerViewValue == 2 {
                    Text("\(stop1Text) to \(stop2Text)")
                        .font(.headline)
                        .foregroundColor(.white)
                    List(startToStop1 ?? []) { obj in
                        Text(obj.step)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
                }
                Spacer()
            }
            .padding(.top, 50)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    InstructionView()
}
