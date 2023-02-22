//
//  LaunchScreen.swift
//  SwiftUI-UserLocation
//
//  Created by Kitty Tyree on 2/8/23.
//
//  Animation that plays before the main page
//  of the app opens.


import SwiftUI

// Custom Diamond Shape
struct Needle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to:CGPoint(x: rect.midX, y:rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))

        return path
    }
}


struct LaunchScreen: View {
    // To control the ring rotation value
    @State private var isRotating = 0.0
    
    // An array of state value animations
    @State var animationValues: [Bool] = Array(repeating: false, count: 6)
    
    var body: some View {
        ZStack{
            // MAIN APP VIEW
            GeometryReader{proxy in
                let size = proxy.size
                
                NavigationTabs()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .offset(y: animationValues[4] ? 0 : (size.height + 50))
            }
            
            if !animationValues[5]{
                // SPLASH SCREEN
                VStack{
                    ZStack{
                        if animationValues[0]{
                            // Inner Compass Shape
                            Circle()
                                .stroke(Color.black, lineWidth: 10)
                                .frame(width: 250, height: 250)
                            
                                .overlay(
                                    Needle()
                                        .fill(.red)
                                        .frame(width:168, height: 43)
                                        .overlay(
                                            Needle()
                                                .trim(from: -0.93, to: 0.665)
                                                .frame(width:168, height: 6)
                                                .rotationEffect(Angle(degrees: 180))
                                        )
                                        .overlay(
                                            Needle()
                                                .trim(from: -0.93, to: 0.665)
                                                .fill(.black)
                                                .frame(width:168, height: 43)
                                        )
                                        .overlay(
                                            Needle()
                                                .trim(from: -0.93, to: 0.665)
                                                .fill(.gray)
                                                .frame(width:168, height: 6)
                                        )
                                )
                                .rotationEffect(Angle(degrees: 168))
                                .scaleEffect(animationValues[1] ? 0.75 : 1)
                                .ignoresSafeArea()
                        }
                        
                        Circle() // Compass Outer Ring
                            .trim(from: 0, to: 0.65)
                            .stroke(Color.black, lineWidth: 10)
                            .frame(width: 325, height: 325)
                            .rotationEffect(.degrees(isRotating))
                            .onAppear {
                                withAnimation(
                                    .linear(duration: 1)
                                    .speed(0.2)
                                    .repeatForever(autoreverses: false)) {
                                        isRotating = 360.0
                                    }
                            }.opacity(animationValues[2] ? 1 : 0)
                    }
                    
                    // App Title
                    Text("Location App")
                        .font(.title.bold())
                        .offset(y: animationValues[3] ? 25 : 0)
                        .opacity(animationValues[3] ? 1 : 0)
                }
                .opacity(animationValues[4] ? 0 : 1)
                .environment(\.colorScheme,
                              .light)
            }
        }
        .onAppear {
            
                //Begin Animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                animationValues[0] = true
                
                
                // Slam in place
                withAnimation(.easeInOut(duration: 0.4).delay(0.1)){
                    animationValues[1] = true
                }
                
                // Rotate outer ring
                withAnimation(.easeInOut(duration: 0.9).delay(0.4)){
                    animationValues[2] = true
                }

                
                // Show title
                withAnimation(.easeInOut(duration: 0.4).delay(2.8)){
                    animationValues[3] = true
                }
                
                // Stop outer ring
                withAnimation(.easeInOut(duration: 0.1).delay(3.0)){
                    isRotating = 224.0
                }


                // End splash screen
                withAnimation(.easeInOut(duration: 0.7).delay(4.4)){
                    animationValues[4] = true
                }

                // For performance, remove splash screen after 2 seconds
                withAnimation(.easeInOut(duration: 0.1).delay(6.4)){
                    animationValues[5] = true
                }

            }
        }
    }
}


struct LauncgScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
