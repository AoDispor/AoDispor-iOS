//
//  AoDisporAPI.swift
//  Ao Dispor
//
//  Created by André Lamelas on 17/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import Siesta
import SwiftyJSON
import CoreLocation

let AoDisporAPI = _AoDisporAPI()

/*fileprivate class CustomAPI: Service {
    init(baseURL: String) {
        super.init(baseURL: baseURL)
    }

    var perfis: Resource { return resource("/profiles") }
}*/

class _AoDisporAPI {

    //private let service = Service(baseURL: "https://api.aodispor.pt")
    private let service = Service(baseURL: "http://dev.api.aodispor.pt")

    //private let service = CustomAPI(baseURL: "http://dev.api.aodispor.pt")

    fileprivate init() {
        #if DEBUG
            // Bare-bones logging of which network calls Siesta makes:
            //LogCategory.enabled = [.network]

            // For more info about how Siesta decides whether to make a network call,
            // and when it broadcasts state updates to the app:
            //LogCategory.enabled = LogCategory.common

            // For the gory details of what Siesta’s up to:
            //LogCategory.enabled = LogCategory.detailed
        #endif

        // Global configuration
        service.configure {
            $0.pipeline[.parsing].add(SwiftyJSONTransformer, contentTypes: ["*/json"])
            $0.pipeline[.cleanup].add(ErrorMessageExtractor())
            $0.useNetworkActivityIndicator()
            $0.headers["API-Authorization"] = self.apiAuthorizationHeader
            $0.headers["Authorization"] = self.basicAuthHeader
        }

        service.configure("/users/register") {
            $0.expirationTime = 12
            $0.headers["Authorization"] = nil
        }

        service.configureTransformer("/users/register") {
            ($0.content as JSON).dictionary?["data"].map(Utilizador.init)
        }

        service.configureTransformer("/users/me") {
            ($0.content as JSON).dictionary?["data"].map(Utilizador.init)
        }

        service.configureTransformer("/profiles") {
            Página.init(json: $0.content)
        }

        service.configureTransformer("/profiles/**") {
            ($0.content as JSON).dictionary?["data"].map(Profissional.init)
        }

        service.configureTransformer("/location/*/*") {
            ($0.content as JSON).dictionary?["data"].map(CódigoPostal.init)
        }

        if let path = Bundle.main.path(forResource: "Configuracoes", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let storable = dict["API-Authorization"] as? String {
            self.apiTokenValue = storable
        }
    }

    // MARK: Registo (pedir password)
    func registar(_ telefone: String) -> Request {
        return service.resource("/users/register").request(.post, json: ["telephone": telefone])
    }

    // MARK: Utilizador
    func meuUtilizador() -> Request {
        return service.resource("/users/me").request(.get)
    }

    func alterarMeuCódigoPostal(cp4: String, cp3: String) -> Request {
        return service.resource("/users/me").request(.post, json: ["postal_code": "\(cp4)-\(cp3)"])
    }

    // MARK: Perfis
    func procurar(parâmetros: [String:String]) -> Request {
//    func procurar(_ query: String, latitude: Double = .nan, longitude: Double = .nan) -> Request {
        var resource = service.resource("/profiles")

        parâmetros.forEach { (chave:String, valor:String) in
            resource = resource.withParam(chave, valor)
        }
        return resource.request(.get)
    }

    func perfil(_ string_id: String) -> Request {
        return service.resource("/profiles").child(string_id).request(.get)
    }


    // MARK: Pedidos

    // MARK: Código Postal
    func códigoPostal(cp4: String, cp3: String) -> Request {
        return service.resource("/location").child(cp4).child(cp3).request(.get)
    }

    // Token de autenticação da API (carregado do ficheiro ao iniciar)
    private var apiTokenValue: String?

    // Header de autenticação da API
    private var apiAuthorizationHeader: String? {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let utcString = formatter.string(from: Date())
            if let unwrappedApiTokenvalue = self.apiTokenValue {
                return "\(unwrappedApiTokenvalue)\(utcString)"
            }
            return nil
        }
    }

    // MARK: Autenticação
    // NOTE: veio direitinho do exemplo do Siesta
    func autenticar(telefone: String, password: String) {
        if let auth = "\(telefone):\(password)".data(using: String.Encoding.utf8) {
            basicAuthHeader = "Basic \(auth.base64EncodedString())"
        }
    }

    func sair() {
        basicAuthHeader = nil
    }

    var estáAutenticado: Bool {
        return basicAuthHeader != nil
    }

    private var basicAuthHeader: String? {
        didSet {
            service.invalidateConfiguration()
            service.wipeResources()
        }
    }
}

/// If the response is JSON and has a "message" value, use it as the user-visible error message.
private struct ErrorMessageExtractor: ResponseTransformer {
    func process(_ response: Response) -> Response {
        switch response {
        case .success:
            return response

        case .failure(var error):
            // Note: the .json property here is defined in Siesta+SwiftyJSON.swift
            error.userMessage = error.json["message"].string ?? error.userMessage
            return .failure(error)
        }
    }
}
