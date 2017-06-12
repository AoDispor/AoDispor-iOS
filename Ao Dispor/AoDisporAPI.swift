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
import Locksmith

let AoDisporAPI = AoDisporAPISiesta()

let NOME_DA_CONTA = "pt.aodispor.ios"

class AoDisporAPISiesta {

    #if (arch(i386) || arch(x86_64)) && os(iOS)
    private let service = Service(baseURL: "http://dev.api.aodispor.pt")
    #else
    private let service = Service(baseURL: "https://api.aodispor.pt")
    #endif

    fileprivate init() {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            // Bare-bones logging of which network calls Siesta makes:
            //LogCategory.enabled = [.network]

            // For more info about how Siesta decides whether to make a network call,
            // and when it broadcasts state updates to the app:
            //LogCategory.enabled = LogCategory.common

            // For the gory details of what Siesta’s up to:
            //LogCategory.enabled = LogCategory.detailed
        #endif

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

        service.configureTransformer("/users/me/profile") {
            ($0.content as JSON).dictionary?["data"].map(Profissional.init)
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

    func meuPerfil() -> Request {
        return service.resource("/users/me/profile").request(.get)
    }

    // MARK: Perfis
    func procurar(parâmetros: [String:String]) -> Request {
        var resource = service.resource("/profiles")

        parâmetros.forEach { (chave: String, valor: String) in
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcString = formatter.string(from: Date())
        if let unwrappedApiTokenvalue = self.apiTokenValue {
            return "\(unwrappedApiTokenvalue)\(utcString)"
        }
        return nil
    }

    // MARK: Autenticação
    func autenticar() {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: NOME_DA_CONTA)
        if dictionary == nil {
            return
        }

        let telefone = dictionary?["telefone"] as! String
        let password = dictionary?["password"] as! String

        basicAuthHeader = gerarAuthString(telefone: telefone, password: password)
    }

    func autenticar(telefone: String, password: String) {
        do {
            try Locksmith.updateData(data: ["telefone": telefone, "password": password], forUserAccount: NOME_DA_CONTA)
        } catch {
            print("Não foi possível gravar os seus dados")
            return
        }
        basicAuthHeader = gerarAuthString(telefone: telefone, password: password)
    }

    func sair() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: NOME_DA_CONTA)
        } catch {
            print("Não foi possível apagar os seus dados")
            return
        }

        basicAuthHeader = nil
    }

    var estáAutenticado: Bool {
        return basicAuthHeader != nil
    }

    private func gerarAuthString(telefone:String, password: String) -> String {
        // NOTE: veio direitinho do exemplo do Siesta
        if let auth = "\(telefone):\(password)".data(using: String.Encoding.ascii) {
            return "Basic \(auth.base64EncodedString())"
        }
        return ""
    }

    private var basicAuthHeader: String? = nil {
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
