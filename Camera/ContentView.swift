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
                    CameraEditView(cameraId: camera.cameraId, macroId: camera.macro.macroId, zoomId: camera.zoom.zoomId, name: camera.name, lenses: camera.lenses, filters: camera.filters,mKelvin: String(camera.macro.kelvin), mTint: String(camera.macro.tint), zKelvin: String(camera.zoom.kelvin), zTint: String(camera.zoom.tint))
                        .onDisappear(perform: {
                            GetCameras(){ response in
                                cameras = response
                            }
                        })
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
                    AddCameraView()
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
    @State var cameraId: Int
    @State var macroId: Int
    @State var zoomId: Int
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
            NavigationLink{
                LenseAdd(lenses: $lenses)
            } label: {
                Text("Add Lense")
            }
            List{
                ForEach(lenses, id: \.lenseId){ lense in
                    NavigationLink{
                        LenseEdit(lenses: $lenses, lense: lense, tint: String(lense.tint), kelvin: String(lense.kelvin), name: lense.name)
                    } label: {
                        Text("Lense \(lense.name)")
                    }
                }}.listRowSeparatorTint(.black)
            NavigationLink{
                FilterAdd(filters: $filters)
            } label: {
                Text("Add Filter")
            }
            List{
                ForEach(filters, id: \.filterId){ filter in
                    NavigationLink{
                        FilterEdit(filters: $filters, filter: filter, tint: String(filter.tint), kelvin: String(filter.kelvin), name: filter.name)
                    } label: {
                        Text("Filter \(filter.name)")
                    }
                }}.listRowSeparatorTint(.black)
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
    @State var name : String = ""
    @State var lenses: [Lense] = []
    @State var filters: [Filter] = []
    @State var mKelvin: String = "0"
    @State var mTint: String = "0"
    @State var zKelvin: String = "0"
    @State var zTint:String = "0"
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            
            NavigationLink{
                LenseAdd(lenses: $lenses)
            } label: {
                Text("Add Lense")
            }
            List{
                ForEach(lenses, id: \.lenseId){ lense in
                    NavigationLink{
                        LenseEdit(lenses: $lenses, lense: lense, tint: String(lense.tint), kelvin: String(lense.kelvin),name: lense.name)
                    } label: {
                        Text("Lense \(lense.name)")
                    }
                }}.listRowSeparatorTint(.black)
            NavigationLink{
                FilterAdd(filters: $filters)
            } label: {
                Text("Add Filter")
            }
            List{
                ForEach(filters, id: \.filterId){ filter in
                    NavigationLink{
                        FilterEdit(filters: $filters, filter: filter, tint: String(filter.tint), kelvin: String(filter.kelvin), name: filter.name)
                    } label: {
                        Text("Filter \(filter.name)")
                    }
                }}.listRowSeparatorTint(.black)
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
    @Binding var lenses:[Lense]
    @State var tint: String = "0"
    @State var kelvin: String = "0"
    @State var name: String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            HStack{
                Text("Tint:")
                TextField("tint",text: $tint)
            }
            HStack{
                Text("Kelvin:")
                TextField("Kelvin",text: $kelvin)
            }
            Spacer()
        }
    }
}
struct LenseEdit: View{
    @Binding var lenses:[Lense]
    @State var lense: Lense
    @State var tint: String
    @State var kelvin: String
    @State var name: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            HStack{
                Text("Tint:")
                TextField("tint",text: $tint)
            }
            HStack{
                Text("Kelvin:")
                TextField("Kelvin",text: $kelvin)
            }
            Spacer()
        }
    }
}
struct FilterEdit: View{
    @Binding var filters:[Filter]
    @State var filter: Filter
    @State var tint: String
    @State var kelvin: String
    @State var name: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            HStack{
                Text("Tint:")
                TextField("tint",text: $tint)
            }
            HStack{
                Text("Kelvin:")
                TextField("Kelvin",text: $kelvin)
            }
            Spacer()
        }.navigationTitle("Edit Filter")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:  Button("Cancel"){
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save"){
                guard let kelvinInt: Int = Int(kelvin) else {
                    print("Not a number")
                    return
                }
                guard let tintInt: Int = Int(tint) else {
                    print("Not a number")
                    return
                }
                guard let idx = filters.firstIndex(where: { $0.filterId == filter.filterId })
                else{
                    return
                }
                filters[idx] = Filter(filterId: filter.filterId, name: name, kelvin: kelvinInt, tint: tintInt)
                presentationMode.wrappedValue.dismiss()
            })
        
    }
}
struct FilterAdd: View{
    @Binding var filters:[Filter]
    @State var tint: String = "0"
    @State var kelvin: String = "0"
    @State var name: String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View{
        VStack{
            HStack{
                Text("Name:")
                TextField("name",text: $name)
            }
            HStack{
                Text("Tint:")
                TextField("tint",text: $tint)
            }
            HStack{
                Text("Kelvin:")
                TextField("Kelvin",text: $kelvin)
            }
            Spacer()
        }.navigationTitle("Add Filter")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:  Button("Cancel"){
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save"){
                guard let kelvinInt: Int = Int(kelvin) else {
                    print("Not a number")
                    return
                }
                guard let tintInt: Int = Int(tint) else {
                    print("Not a number")
                    return
                }
                filters.append(Filter(filterId: 0, name: name, kelvin: kelvinInt, tint: tintInt))
                presentationMode.wrappedValue.dismiss()
            })
    }
}

