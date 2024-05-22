//
//  VolumeView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/16/24.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct VolumeView: View {
    
    
    
    @State var modelName: String
    @State var lastGestureValueX = CGFloat(0)
    @State var lastGestureValueY = CGFloat(0)
    
    @State private var rotateBy: Double = 0.0
    
    @State var isDragging: Bool = false
        @State var rotation: Angle = .zero
    
    var drag: some Gesture {
            DragGesture()
                .onChanged { _ in
                    isDragging = true
                    rotation.degrees += 5.0
                }
                .onEnded { _ in
                    isDragging = false
                }
        }
    
    var body: some View {
        Model3D(named: modelName)
//        RealityView { content in
//            do {
//                let entity = try await Entity.init(named: modelName, in: realityKitContentBundle)
//                entity.position = SIMD3<Float>(x:0, y:-0.2, z:0)
//                entity.scale = SIMD3<Float>(repeating: 2)
//
//                content.add(entity)
//            }
//            catch {
//                print(error)
//            }
//        }
//        .rotation3DEffect(.radians(rotateBy), axis: .y)
//        .gesture(
//            drag)
//        .rotation3DEffect(rotation, axis: .xy)
            
            
//            DragGesture(minimumDistance: 0.0)
//                                .targetedToAnyEntity()
//                                .onChanged { value in
//                                    print("rotating")
//                                    let location3d = value.convert(value.location3D, from: .local, to: .scene)
//                                    let startLocation = value.convert(value.startLocation3D, from: .local, to: .scene)
//
//                                    let delta = location3d - startLocation
//
//                                    rotateBy = Double(atan(delta.x * 100))
            
            
            
//                                    let entity = value.entity
//                                    var orientation = Rotation3D(entity.orientation(relativeTo: nil))
//                                    var newOrientation: Rotation3D
//            //                      let newOrientationY: Rotation3D
//
//                                    if (value.location.x >= lastGestureValueX) {
//                                        newOrientation = orientation.rotated(by: .init(angle: .degrees(1.0), axis: .y))
//                                    } else {
//                                        newOrientation = orientation.rotated(by: .init(angle: .degrees(-1.0), axis: .y))
//                                    }
//                                    entity.setOrientation(.init(newOrientation), relativeTo: nil)
//                                    print("x:", lastGestureValueX)
//                                    lastGestureValueX = value.location.x
//                                    print("x:", lastGestureValueX)
//                                    orientation = Rotation3D(entity.orientation(relativeTo: nil))
//                                    if (value.location.y >= lastGestureValueY) {
//                                        newOrientation = orientation.rotated(by: .init(angle: .degrees(1.0), axis: .x))
//                                    } else {
//                                        newOrientation = orientation.rotated(by: .init(angle: .degrees(-1.0), axis: .x))
//                                    }
//                                    entity.setOrientation(.init(newOrientation), relativeTo: nil)
//                                    lastGestureValueY = value.location.y
                                    
                                    
                                    
//                                }
//        )
            
//        Model3D(named: modelName) { model in
//            model
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//        } placeholder: {
//            ProgressView()
//        }
        
        
    }
    
    
}
