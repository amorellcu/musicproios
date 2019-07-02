//
//  AppError.swift
//  musicprof
//
//  Created by John Doe on 6/21/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation

enum AppError: String, Error {
    case unexpected = "Ocurrió un error inesperado en la aplicación."
    case notAnError = "Error interno."
    case unsupportedData = "Se recibieron datos erroneos del serivdor. Por favor, asegúrese de tener la última versión de la aplicación."
    case invalidOperation = "No se puede ejecutar la operación en este momento."
    case registrationRequired = "Por favor, complete su registro en el sistema."
}

extension AppError: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
