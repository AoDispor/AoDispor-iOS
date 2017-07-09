//
//  CardStackViewController.swift
//  Ao Dispor
//
//  Created by André Lamelas on 15/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit
import Koloda
import Siesta
import Crashlytics
import MessageUI
import SwiftLocation
import Pulsator
import SwiftIconFont

class CardStackViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var kolodaView: KolodaViewCartas!
    @IBOutlet weak var pulsatorView: UIView!

    var página: Página?

    var profissionais: [Profissional] {
        return página == nil ? [] : página!.profissionais
    }

    var pesquisouPor: String = ""

    fileprivate var pesquisaFoiComeçada: CFAbsoluteTime?
    fileprivate let duraçãoDaAnimaçãoDoRadar = 2.0 //2 segundos

    fileprivate let pulsator = Pulsator()
    fileprivate let loadingText = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        kolodaView.dataSource = self
        kolodaView.delegate = self

        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("De quem precisa?", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.configurarBarraDeNavegação()
        self.configurarVistaDoRadar()

        self.fazerReset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Configurações visuais
    private func configurarBarraDeNavegação() {
        let titleView = UILabel()
        titleView.text = "Ao Dispor"
        titleView.font = UIFont(name: "DancingScriptOT", size: 36)
        titleView.textColor = UIColor.white

        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 44))
        self.navigationItem.titleView = titleView

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(CardStackViewController.fazerReset))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)

        let botãoEsquerdo = UIBarButtonItem(title: NSLocalizedString("Anterior", comment:""), style: .done, target: self, action: #selector(CardStackViewController.cartaAnterior))
        botãoEsquerdo.tintColor = UIColor.white
        botãoEsquerdo.icon(from: .FontAwesome, code: "undo", ofSize: 20)
        self.navigationItem.leftBarButtonItem = botãoEsquerdo

        let botãoDireito = UIBarButtonItem(title: NSLocalizedString("O Seu Perfil", comment:""), style: .done, target: self, action: #selector(CardStackViewController.mostraPerfil))
        botãoDireito.tintColor = UIColor.white
        botãoDireito.icon(from: .FontAwesome, code: "user", ofSize: 20)
        self.navigationItem.rightBarButtonItem = botãoDireito

        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.barTintColor = UIColor.titleBlue
    }

    private func configurarVistaDoRadar() {
        loadingText.text = NSLocalizedString("Estamos a procurar profissionais à sua volta", comment: "")
        loadingText.sizeToFit()
        loadingText.numberOfLines = 2
        loadingText.textAlignment = .center
        loadingText.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 50)
        loadingText.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.25)
        pulsatorView.addSubview(loadingText)

        pulsator.numPulse = 6
        pulsator.radius = 320
        pulsator.animationDuration = 6
        pulsator.backgroundColor = UIColor.titleBlue.cgColor
        pulsator.position = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        pulsator.start()
        pulsatorView.layer.addSublayer(pulsator)
    }

    // MARK: - Pesquisa e afins
    func procurarPor(_ parâmetros: [String:String]) {
        // Esconder os cartões
        kolodaView.isHidden = true
        pulsatorView.isHidden = false

        var parâmetrosLocais = parâmetros

        if parâmetrosLocais["query"] != nil && !(parâmetrosLocais["query"]?.isEmpty)! {
            pesquisouPor = parâmetrosLocais["query"]!
        } else {
            parâmetrosLocais.removeValue(forKey: "query")
        }

        pesquisaFoiComeçada = CFAbsoluteTimeGetCurrent()
        Location.getLocation(accuracy: .block, frequency: .oneShot, timeout: 5, cancelOnError: true, success: { (_, location) in
            parâmetrosLocais["lat"] = String(location.coordinate.latitude)
            parâmetrosLocais["lon"] = String(location.coordinate.longitude)
            self.executarPesquisa(parâmetrosLocais)
        }) { (_, _, error) -> Void in
            print("Location monitoring failed due to an error \(error)")
            self.executarPesquisa(parâmetrosLocais)
        }
    }

    func fazerReset() {
        self.searchBar!.text = ""
        self.pesquisouPor = ""
        self.procurarPor(["query": ""])
    }

    func executarPesquisa(_ parâmetros: [String:String]) {
        AoDisporAPI.procurar(parâmetros: parâmetros).onSuccess { data in
            self.página = data.typedContent()! as Página
        }.onCompletion { _ in
            self.noFimDaPesquisa()
        }
    }

    func noFimDaPesquisa() {
        let passaramSegundos = CFAbsoluteTimeGetCurrent() - pesquisaFoiComeçada!
        if passaramSegundos >= duraçãoDaAnimaçãoDoRadar {
            self.escondeRadarMostraCartas()
            return
        }

        let diferença =  duraçãoDaAnimaçãoDoRadar - passaramSegundos

        //isto veio daqui e é feio: http://stackoverflow.com/questions/27517632/how-to-create-a-delay-in-swift
        DispatchQueue.main.asyncAfter(deadline: .now() + diferença, execute: {
            self.escondeRadarMostraCartas()
        })
    }

    func escondeRadarMostraCartas() {
       self.kolodaView.resetCurrentCardIndex()
       UIView.animate(withDuration: 0.25, animations: {
            self.pulsatorView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finished) in
            if finished {
                self.kolodaView.isHidden = false
                self.pulsatorView.isHidden = true
                UIView.animate(withDuration: 0, animations: {
                    self.pulsatorView.transform = CGAffineTransform.identity
                })
            }
        }
    }

    func cartaAnterior() {
        if self.kolodaView.currentCardIndex == 0 {
            return
        }

        self.kolodaView.revertAction()
    }

    func mostraPerfil() {
        if AoDisporAPI.estáAutenticado {
            self.performSegue(withIdentifier: "mostraPerfil", sender: self)
        } else {
            self.performSegue(withIdentifier: "pedeNúmeroDeTelefone", sender: self)
        }
    }

    func recognizeTap() {
        self.kolodaView.delegate?.koloda(kolodaView, didSelectCardAt: self.kolodaView.currentCardIndex)
    }
}

// MARK: - KolodaViewDataSource
extension CardStackViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        if profissionais.isEmpty {
            return 1 // para mostrar a carta de "ups, não há aqui nada"
        }

        if (self.página?.temMaisPáginas)! {
            return profissionais.count // se tiver multiplas páginas mostra só o número de cartões (carrega mais quando chega ao fim)
        }

        // tendo cartões e só uma página, retorna o numero de cartões mais 1 (para mostrar o final)
        return profissionais.count + 1
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if profissionais.isEmpty && index == 0 {
            return CartãoTextoImagem.criarCartão(texto: "", subtexto: "Parece que não existem resultados.", imagem: UIImage(named: "Fim de Busca")!)
        }

        // como os indices começam no zero, o último é igual ao count
        if !profissionais.isEmpty && index == self.profissionais.count {
            return CartãoTextoImagem.criarCartão(texto: "É tudo", subtexto: "Parece que chegamos ao final dos resultados do que procurou.", imagem: UIImage(named: "Fim de Busca")!)
        }

        let cartãoProfissional = Bundle.main.loadNibNamed("CartãoProfissional", owner: self, options: nil)![0] as? CartãoProfissional
        let profissional = profissionais[Int(index)]

        cartãoProfissional?.preencherComDados(profissional: profissional)

        let tapCatcher = UITapGestureRecognizer(target: self, action: #selector(CardStackViewController.recognizeTap))
        tapCatcher.numberOfTapsRequired = 1
        tapCatcher.numberOfTouchesRequired = 1
        tapCatcher.delegate = self
        cartãoProfissional?.descriçãoDoPerfil?.addGestureRecognizer(tapCatcher)

        return cartãoProfissional!
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CardStackViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - KolodaViewDelegate
extension CardStackViewController: KolodaViewDelegate {
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        // TODO: Era fixe isto permitir a animação quando a pilha estivesse no fim
        //return koloda.currentCardIndex == self.profissionais.count ? true : false
        return true
    }

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        if (self.página?.temMaisPáginas)! {
            procurarPor(["query": pesquisouPor,
                         "page": (self.página?.páginaSeguinte.description)!])
        }
        self.kolodaView.resetCurrentCardIndex()
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let profissional = profissionais[index]

        let alertController = UIAlertController(title: profissional.nomeCompleto, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment:""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: NSLocalizedString("Telefonar", comment:""), style: .default) { (_) in
            let phone = "tel://\(profissional.telefone)"
            let open = URL(string: phone)!
            Answers.logCustomEvent(withName: "Telefonema", customAttributes: ["string_id": profissional.stringId
                ])
            UIApplication.shared.openURL(open)
        }
        alertController.addAction(OKAction)

        let SMSAction = UIAlertAction(title: NSLocalizedString("Enviar SMS", comment:""), style: .default) { (_) in
            let messageVC = MFMessageComposeViewController()
            messageVC.body = NSLocalizedString("Vi o seu perfil no AoDispor.pt e gostaria de contratar os seus serviços. Podemos falar?", comment: "")
            messageVC.recipients = [profissional.telefone]
            messageVC.messageComposeDelegate = self
            Answers.logCustomEvent(withName: "Envio de SMS", customAttributes: ["string_id": profissional.stringId
                ])
            self.present(messageVC, animated: true, completion: nil)
        }
        alertController.addAction(SMSAction)

        let ShareAction = UIAlertAction(title: NSLocalizedString("Partilhar", comment: ""), style: .default) { (_) in
            let profissionalToShare = profissional
            let url = "http://www.aodispor.pt/\(profissionalToShare.stringId)"
            let profissionalURL = NSURL(string: url)
            let objectsToShare: [AnyObject] = [profissionalURL!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
        alertController.addAction(ShareAction)

        self.present(alertController, animated: true, completion: nil)
    }

}

// MARK: - MFMessageComposeViewControllerDelegate
extension CardStackViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension CardStackViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text! = self.pesquisouPor
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)

        self.procurarPor(["query": searchBar.text!])
    }
}
