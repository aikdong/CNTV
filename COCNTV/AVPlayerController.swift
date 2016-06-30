
import UIKit
import AVFoundation

class AVPlayerController: UIViewController {
    
    var player: AVPlayer!
    var url: NSURL!
    
    init(url: NSURL!) {
        self.url = url;
        self.player = AVPlayer(URL: self.url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = AVPlayerLayer(player: player)
        
        layer.frame = self.view.frame
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill

        self.view.layer.addSublayer(layer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    internal func play() {
        player.play()
    }
    
    internal func pause() {
        player.pause()
    }
    
}
