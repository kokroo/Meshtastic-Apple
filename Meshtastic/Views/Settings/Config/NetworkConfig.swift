//
//  WiFiConfig.swift
//  Meshtastic
//
//  Copyright (c) Garth Vander Houwen 8/1/2022
//

import SwiftUI

struct NetworkConfig: View {
	
	@Environment(\.managedObjectContext) var context
	@EnvironmentObject var bleManager: BLEManager
	
	var node: NodeInfoEntity?
	
	@State private var isPresentingSaveConfirm: Bool = false
	@State var initialLoad: Bool = true
	@State var hasChanges: Bool = false
	
	@State var wifiEnabled = false
	@State var wifiSsid = ""
	@State var wifiPsk = ""
	@State var wifiMode = 0
	
	var body: some View {
		
		VStack {
			
			Form {
				
				Section(header: Text("WiFi Options")) {
					
					Text("Enabling WiFi will disable the bluetooth connection to the app.")
						.font(.title3)
						
					Toggle(isOn: $wifiEnabled) {

						Label("Enabled", systemImage: "wifi")
					}
					.toggleStyle(SwitchToggleStyle(tint: .accentColor))
					

					Picker("Mode", selection: $wifiMode ) {
						ForEach(WiFiModes.allCases) { lu in
							Text(lu.description)
						}
					}
					.pickerStyle(DefaultPickerStyle())
					
					HStack {
						Label("SSID", systemImage: "network")
						TextField("SSID", text: $wifiSsid)
							.foregroundColor(.gray)
							.autocapitalization(.none)
							.disableAutocorrection(true)
							.onChange(of: wifiSsid, perform: { value in

								let totalBytes = wifiSsid.utf8.count
								
								// Only mess with the value if it is too big
								if totalBytes > 32 {

									let firstNBytes = Data(wifiSsid.utf8.prefix(32))
							
									if let maxBytesString = String(data: firstNBytes, encoding: String.Encoding.utf8) {
										
										// Set the shortName back to the last place where it was the right size
										wifiSsid = maxBytesString
									}
								}
								hasChanges = true 
							})
							.foregroundColor(.gray)
					}
					.keyboardType(.default)
					
					HStack {
						Label("Password", systemImage: "wallet.pass")
						TextField("Password", text: $wifiPsk)
							.foregroundColor(.gray)
							.autocapitalization(.none)
							.disableAutocorrection(true)
							.onChange(of: wifiPsk, perform: { value in

								let totalBytes = wifiPsk.utf8.count
								
								// Only mess with the value if it is too big
								if totalBytes > 63 {

									let firstNBytes = Data(wifiPsk.utf8.prefix(63))
							
									if let maxBytesString = String(data: firstNBytes, encoding: String.Encoding.utf8) {
										
										// Set the shortName back to the last place where it was the right size
										wifiPsk = maxBytesString
									}
								}
								hasChanges = true
							})
							.foregroundColor(.gray)
					}
					.keyboardType(.default)
				}
			}
			.disabled(!(node != nil && node!.myInfo?.hasWifi ?? false))
			
			Button {
							
				isPresentingSaveConfirm = true
				
			} label: {
				
				Label("Save", systemImage: "square.and.arrow.down")
			}
			.disabled(bleManager.connectedPeripheral == nil || !hasChanges)
			.buttonStyle(.bordered)
			.buttonBorderShape(.capsule)
			.controlSize(.large)
			.padding()
			.confirmationDialog(
				
				"Are you sure you want to save?",
				isPresented: $isPresentingSaveConfirm,
				titleVisibility: .visible
			) {
				Button("Save Config for \(bleManager.connectedPeripheral != nil ? bleManager.connectedPeripheral.longName : "Unknown")") {
					
					var network = Config.NetworkConfig()
					network.wifiEnabled = self.wifiEnabled
					network.wifiSsid = self.wifiSsid
					network.wifiPsk = self.wifiPsk
					network.wifiMode = WiFiModes(rawValue: self.wifiMode)?.protoEnumValue() ?? WiFiModes.client.protoEnumValue()
					
					let adminMessageId =  bleManager.saveWiFiConfig(config: network, fromUser: node!.user!, toUser: node!.user!)
					
					if adminMessageId > 0 {
						
						// Should show a saved successfully alert once I know that to be true
						// for now just disable the button after a successful save
						self.hasChanges = false
						
					} else {
						
					}
				}
			} message: {
				
				Text("After network config saves the node will reboot.")
			}
		}
		.navigationTitle("Network Config")
		.navigationBarItems(trailing:

			ZStack {

			ConnectedDevice(bluetoothOn: bleManager.isSwitchedOn, deviceConnected: bleManager.connectedPeripheral != nil, name: (bleManager.connectedPeripheral != nil) ? bleManager.connectedPeripheral.shortName : "????")
		})
		.onAppear {

			if self.initialLoad{
				
				self.bleManager.context = context

				self.wifiEnabled = (node!.networkConfig?.wifiEnabled ?? false)
				self.wifiSsid = node!.networkConfig?.wifiSsid ?? ""
				self.wifiPsk = node!.networkConfig?.wifiPsk ?? ""
				self.wifiMode = Int(node!.networkConfig?.wifiMode ?? 0)

				self.hasChanges = false
				self.initialLoad = false
			}
		}
		.onChange(of: wifiEnabled) { newEnabled in
			
			if node != nil && node!.networkConfig != nil {
				
				if newEnabled != node!.networkConfig!.wifiEnabled { hasChanges = true }
			}
		}
		.onChange(of: wifiSsid) { newSSID in
			
			if node != nil && node!.networkConfig != nil {
				
				if newSSID != node!.networkConfig!.wifiSsid { hasChanges = true }
			}
		}
		.onChange(of: wifiPsk) { newPsk in
			
			if node != nil && node!.networkConfig != nil {
				
				if newPsk != node!.networkConfig!.wifiPsk { hasChanges = true }
			}
		}
		.onChange(of: wifiMode) { newMode in
			
			if node != nil && node!.networkConfig != nil {
				
				if newMode != node!.networkConfig!.wifiMode { hasChanges = true }
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
