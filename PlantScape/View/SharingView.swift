//
//  SharingView.swift
//  PlantScape
//
//  Created by Daud on 03/06/24.
//

import SwiftUI

struct SharingView: View {
    @EnvironmentObject var multipeerSession: MultipeerSession

    @Binding var isSheetPresented: Bool
    
    var plant: Plant
        
    var body: some View {
        VStack{
            if (!multipeerSession.paired) {
                List(multipeerSession.availablePeers, id: \.self) { peer in
                    Button(peer.displayName) {
                        multipeerSession.serviceBrowser.invitePeer(peer, to: multipeerSession.session, withContext: nil, timeout: 30)
                    }
                }
                .alert("Received an invite from \(multipeerSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $multipeerSession.recvdInvite) {
                    Button("Accept invite") {
                        if (multipeerSession.invitationHandler != nil) {
                            multipeerSession.invitationHandler!(true, multipeerSession.session)
                        }
                    }
                    Button("Reject invite") {
                        if (multipeerSession.invitationHandler != nil) {
                            multipeerSession.invitationHandler!(false, nil)
                        }
                    }
                }
            } else {
                List {
                    HStack {
                        Text("Connected: '\(multipeerSession.session.connectedPeers[0].displayName)'")
                        Spacer()
                        Button("Send Plant") {
                            multipeerSession.sendPlant(plant: plant)
                            isSheetPresented = false
                        }.foregroundColor(.blue)
                    }
                    ForEach(multipeerSession.availablePeers, id: \.self) { peer in
                        Text("\(peer.displayName)")
                    }
                }
            }
        }
        .textInputAutocapitalization(.never).disableAutocorrection(true)
        .navigationBarTitle("List Active Device", displayMode: .inline)
        .navigationBarItems(
            trailing:Button("Cancel"){
                isSheetPresented = false
            }.foregroundColor(.red)
        )
    }
}
