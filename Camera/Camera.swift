//
//  Camera.swift
//  Camera
//
//  Created by John Barnett on 8/1/22.
//

import Foundation

struct Camera: Codable, Equatable {
    static func == (lhs: Camera, rhs: Camera) -> Bool {
        return  lhs.cameraId == rhs.cameraId && lhs.name == rhs.name
    }
    
    let cameraId: Int
    let name: String
    let lenses: [Lense]
    let filters: [Filter]
    let macro: Macro
    let zoom : Zoom
}
struct Lense: Codable {
    let lenseId: Int
    let name: String
    let kelvin: Int
    let tint: Int
}
struct Filter: Codable {
    let filterId: Int
    let name: String
    let kelvin: Int
    let tint: Int
}
struct Macro: Codable{
    let macroId: Int
    let kelvin: Int
    let tint: Int
}
struct Zoom: Codable{
    let zoomId: Int
    let kelvin: Int
    let tint: Int
}
