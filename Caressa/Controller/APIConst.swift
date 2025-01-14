//
//  APIConst.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import Foundation

public class APIConst {
    
    public static var baseURL                  = "https://caressa.herokuapp.com"
    public static let facilityId               = SessionManager.shared.facilityId
    
    // MARK: Login
    public static let token                    = "/o/token/"
    public static let forgotPassword           = "https://caressa.herokuapp.com/accounts/password_reset/"
    
    // MARK: Senior List
    public static let facility                 = "/api/facility/\(facilityId)/"
    public static let residents                = "/api/facility/\(facilityId)/residents/"
    //public static let morningCheckIn           = "/api/residents/\(facilityId)/checked/today/"
    public static let morningCheckIn           = "/api/facility/\(facilityId)/residents/?view=morning-check-in"
    //[POST, DELETE]
    public static let residentCheck            = "/api/resident/\(facilityId)/checked/"
    
    // MARK: Messages List
    public static let messages                 = "/api/facility/\(facilityId)/messages/?page="
    
    // MARK: New Message
    public static let residentsAutoComplete    = "/api/facility/\(facilityId)/residents/?starts_with=%@"
    public static let message                  = "/api/facility/\(facilityId)/message/"
    /// For voice message
    public static let messageSignedUrl         = "/api/facility/\(facilityId)/message-signed-urls/"
    
    // MARK: Message thread
    public static let messageThread            = "/api/message-thread/%d/"
    public static let messageThreadsMessage    = "/api/message-thread/%d/messages/"
    
    // MARK: Profile Page
    public static let resident                 = "/api/residents/%d/"
    public static let users                    = "/api/users/%d/"
    public static let userMe                   = "/api/users/me/"
    public static let profilePicSignedUrl      = "/api/users/%d/profile-picture/" //"/api/users/%d/uploaded_new_profile_picture/"
    
    // MARK: Photo Gallery
    public static let photoGallery              = "/api/photo-galleries/\(facilityId)/"
    //public static let photos                   = "/api/photo-galleries/\(facilityId)/photos/"
    public static let photoGalleryDates         = "/api/photo-galleries/\(facilityId)/days/%@/"
    public static let photoGalleryPhotos        = "/api/photo-galleries/\(facilityId)/photos/"
    public static let photoDelete               = "/api/photos/%d/"
    
    // MARK: Calendar
    public static let calendar                  = "/api/calendars/\(facilityId)/?start=%@"
    
    // MARK: Amazon
    public static let generateSignedURL         = "/generate-signed-url/"
    public static let generateSignedURLMultiple = "/generate_signed_url_multiple/"
    
    // MARK: Settings
    public static let facilityProfilePicture    = "/api/facilities/\(facilityId)/profile-picture/"
    
    // MARK: Others
    public static let timeState                 = "/api/facility/\(facilityId)/time-state/"
}
