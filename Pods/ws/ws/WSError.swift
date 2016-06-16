//
//  WSError.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 06/04/16.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

public enum WSError:ErrorType {
    case DefaultError
    case NetworkError
    case UnauthorizedError
    case NotFoundError
}