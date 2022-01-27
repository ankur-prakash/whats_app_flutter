//
//  NoDataView.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 15/01/22.
//

import SwiftUI

struct NoDataView: View {
    let image: Image
    let message: String
    
    var body: some View {
        VStack(spacing: 20.0) {
            image
                .scaleEffect(3)
            Text(message)
                .font(.largeTitle)
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView(image: Image(systemName: "person.badge.plus"), message: "Not Chats Found")
    }
}
