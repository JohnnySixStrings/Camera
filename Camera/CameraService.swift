//
//  CameraService.swift
//  Camera
//
//  Created by John Barnett on 8/6/22.
//

import Foundation

func GetCameras(completionHandler: @escaping ([Camera])-> Void){
    guard let url = URL(string:"http://localhost:8080/cameras") else {
        return
    }
    let decoder = JSONDecoder()
    var request = URLRequest(url:url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    let task = URLSession.shared.dataTask(with: request){ data, _, error in
        guard let data = data, error == nil else {
            return
        }
        do{
            let response = try decoder.decode([Camera].self, from: data)
            completionHandler(response)
        }catch{
            print(error)
        }
    }
    task.resume()
    
}
func AddCamera(camera: Camera){
    guard let url = URL(string:"http://localhost:8080/cameras") else {
        return
    }
    let encoder = JSONEncoder()
    var request = URLRequest(url:url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.httpBody = try? encoder.encode(camera)
    _ = URLSession.shared.dataTask(with: request){ data, _, error in
        guard let data = data, error == nil else {
            return
        }
        do{
            let response = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            print(response)
        }catch{
            print(error)
        }
    }
}
func DeleteCamera(id: Int){
    guard let url = URL(string:"http://localhost:8080/cameras/\(id)") else {
        return
    }
    var request = URLRequest(url:url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    _ = URLSession.shared.dataTask(with: request){ data, _, error in
        guard let data = data, error == nil else {
            return
        }
        do{
            let response = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            print(response)
        }catch{
            print(error)
        }
    }
    
}
func UpdateCamera(camera: Camera){
    guard let url = URL(string:"http://localhost:8080/cameras/\(camera.cameraId)") else {
        return
    }
    let encoder = JSONEncoder()
    var request = URLRequest(url:url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.httpBody = try? encoder.encode(camera)
    _ = URLSession.shared.dataTask(with: request){ data, _, error in
        guard let data = data, error == nil else {
            return
        }
        do{
            let response = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            print(response)
        }catch{
            print(error)
        }
    }
}
