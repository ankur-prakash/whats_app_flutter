//
//  ProfileIcon.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct ProfileIcon: View {
 
    let image: Image
  
    var body: some View {
        image
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.vertical)
            .clipShape(Circle())
    }
}

struct ProfileIcon_Previews: PreviewProvider {
    static var previews: some View {
        ProfileIcon(image: Image("umbagog"))
    }
}
