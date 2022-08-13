//
//  ContentView.swift
//  Camera
//
//  Created by John Barnett on 8/1/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var cameras : [Camera] = []
    var body: some View {
        TabView{
            CalculationView(cameras: $cameras).tabItem{
                Label("Calculate", systemImage: "tray.and.arrow.down.fill")
            }
            NavigationView{
                CameraListView(cameras: $cameras)
            }.tabItem{
                Label("Cameras", systemImage: "tray.and.arrow.down.fill")
            }
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                GetCameras(){ response in
                    cameras = response
                }
            } else if newPhase == .inactive {
                print("inactive")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct CalculationView: View {
    @Binding var cameras : [Camera]
    var body: some View{
        Text("CalculationView")
    }
}
struct CameraListView: View {
    @Binding var cameras : [Camera]
    var body: some View{
        List{
            ForEach(cameras,id: \.cameraId){
                camera in
                NavigationLink{
                    if let idx = cameras.firstIndex(where: {$0 == camera}) {
                        CameraEditView(cameras: $cameras,cameraId: camera.cameraId, macroId: camera.macro.macroId, zoomId: camera.zoom.zoomId ,position: idx, name: camera.name, lenses: camera.lenses, filters: camera.filters,mKelvin: String(camera.macro.kelvin), mTint: String(camera.macro.tint), zKelvin: String(camera.zoom.kelvin), zTint: String(camera.zoom.tint))
                            .onDisappear(perform: {
                                GetCameras(){ response in
                                    cameras = response
                                }
                            })
                    }
                } label:{
                    Text(camera.name)
                }
            }.onDelete(perform: {offset in
                let cameraIds = offset.map{ cameras[$0].cameraId}
                for id in cameraIds {
                    DeleteCamera(id: id)
                }
                cameras.remove(atOffsets:offset )
            })
        }
        .navigationBarTitle("Cameras")
        .toolbar {
            ToolbarItem{
                NavigationLink{
                    AddCameraView(cameras: $cameras)
                        .onDisappear(perform: {
                            GetCameras(){ response in
                                cameras = response
                            }
                        })
                } label: {
                    Text("Add")
                }}
        }
    }
}
struct CameraEditView: View {
    @Binding var cameras: [Camera]
    @State var cameraId: Int
    @State var macroId: Int
    @State var zoomId: Int
    @State var position: Int
    @State var name: String
    @State var lenses: [Lense]
    @State var filters: [Filter]
    @State var mKelvin: String
    @State var mTint: String
    @State var zKelvin: String
    @State var zTint:String
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            ForEach(lenses, id: \.lenseId){ lense in
                NavigationLink{
                    LenseEdit()
                } label: {
                    Text("Lense \(lense.lenseId)")
                }
            }.listRowSeparatorTint(.black)
            ForEach(filters, id: \.filterId){ filter in
                NavigationLink{
                    FilterEdit()
                } label: {
                    Text("Filter \(filter.filterId)")
                }
            }.listRowSeparatorTint(.black)
            VStack{
                Text("Macro")
                HStack{
                    Text("Tint:")
                    TextField("mtint",text: $mTint)
                }
                HStack{
                    Text("Kelvin:")
                    TextField("mKelvin",text: $mKelvin)
                }
            }
            VStack{
                Text("Zoom")
                HStack{
                    Text("Tint:")
                    TextField("mtint",text: $zTint)
                }
                HStack{
                    Text("Kelvin:")
                    TextField("mKelvin",text: $zKelvin)
                }
            }
            Spacer()
        }.navigationBarItems(trailing: Button("Save"){
            guard let macroKelvin: Int = Int(mKelvin) else {
                print("Not a number")
                return
            }
            guard let macroTint: Int = Int(mTint) else {
                print("Not a number")
                return
            }
            guard let zoomKelvin: Int = Int(zKelvin) else {
                print("Not a number")
                return
            }
            guard let zoomTint: Int = Int(zTint) else {
                print("Not a number")
                return
            }
            let camera = Camera(cameraId: cameraId, name: name, lenses: lenses, filters: filters, macro: Macro(macroId: macroId, kelvin: macroKelvin, tint: macroTint), zoom: Zoom(zoomId: zoomId, kelvin: zoomKelvin, tint: zoomTint))
            UpdateCamera(camera: camera)
            
            presentationMode.wrappedValue.dismiss()
        })
        
    }
}
struct AddCameraView :View {
    @Binding var cameras: [Camera]
    @State var name : String = ""
    @State var lenses: [Lense] = []
    @State var filters: [Filter] = []
    @State var mKelvin: String = ""
    @State var mTint: String = ""
    @State var zKelvin: String = ""
    @State var zTint:String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            ForEach(lenses, id: \.lenseId){ lense in
                NavigationLink{
                    LenseEdit()
                } label: {
                    Text("Lense \(lense.lenseId)")
                }
            }.listRowSeparatorTint(.black)
            ForEach(filters, id: \.filterId){ filter in
                NavigationLink{
                    FilterEdit()
                } label: {
                    Text("Filter \(filter.filterId)")
                }
            }.listRowSeparatorTint(.black)
            VStack{
                Text("Macro")
                HStack(alignment: .center, spacing: 10){
                    Text("Tint:")
                    TextField("mtint",text: $mTint)
                }
                HStack{
                    Text("Kelvin:")
                    TextField("mKelvin",text: $mKelvin)
                }
            }
            VStack{
                Text("Zoom")
                HStack{
                    Text("Tint:")
                    TextField("mtint",text: $zTint)
                }
                HStack{
                    Text("Kelvin:")
                    TextField("mKelvin",text: $zKelvin)
                }
            }
            Spacer()
        }.navigationTitle("Add Camera")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:  Button("Cancel"){
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save"){
                guard let macroKelvin: Int = Int(mKelvin) else {
                    print("Not a number")
                    return
                }
                guard let macroTint: Int = Int(mTint) else {
                    print("Not a number")
                    return
                }
                guard let zoomKelvin: Int = Int(zKelvin) else {
                    print("Not a number")
                    return
                }
                guard let zoomTint: Int = Int(zTint) else {
                    print("Not a number")
                    return
                }
                let camera = Camera(cameraId: 0, name: name, lenses: lenses, filters: filters, macro: Macro(macroId: 0, kelvin: macroKelvin, tint: macroTint), zoom: Zoom(zoomId: 0, kelvin: zoomKelvin, tint: zoomTint))
                AddCamera(camera: camera)
                presentationMode.wrappedValue.dismiss()
            })
    }
}

struct LenseAdd: View{
    var body: some View{
        Text("LenseAdd")
    }
}
struct LenseEdit: View{
    var body: some View{
        Text("LenseEdit")
    }
}
struct FilterEdit: View{
    var body: some View{
        Text("FilterEdit")
    }
}

