//
//  MenuViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-19.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var MenuView: UIView!
    let screenRect = UIScreen.main.bounds
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutMenuView()
//        MenuView.frame.size.height = screenRect.height / 1.3
        view.frame.size.height = screenRect.height / 1.3
        
        
        let textView = UITextView(frame: CGRect(x: 11.0, y: 50.0, width: MenuView.bounds.width - 22, height: view.frame.height / 2))
        
        
        
//        textView.center = self.view.center
        textView.textAlignment = NSTextAlignment.justified
        textView.backgroundColor = UIColor.lightGray
        
        // Use RGB colour
        textView.backgroundColor = UIColor(red: 39/255, green: 53/255, blue: 182/255, alpha: 1)
        
        // Update UITextView font size and colour
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = UIColor.white
        
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.font = UIFont(name: "Verdana", size: 17)
        
        // Capitalize all characters user types
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        // Make UITextView web links clickable
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.text = "This is text to Speech Although The Starry Night was painted during the day in Van Gogh's ground-floor studio, it would be inaccurate to state that the picture was painted from memory. The view has been identified as the one from his bedroom window, facing east, a view which Van Gogh painted variations of no fewer than twenty-one times, including The Starry Night. Through the iron-barred window, he wrote to his brother, Theo, around 23 May 1889, I can see an enclosed square of wheat . . . above which, in the morning, I watch the sun rise in all its glory. Van Gogh depicted the view at different times of day and under various weather conditions, including sunrise, moonrise, sunshine-filled days, overcast days, windy days, and one day with rain. While the hospital staff did not allow Van Gogh to paint in his bedroom, he was able there to make sketches in ink or charcoal on paper; eventually he would base newer variations on previous versions. The pictorial element uniting all of these paintings is the diagonal line coming in from the right depicting the low rolling hills of the Alpilles mountains. In fifteen of the twenty-one versions, cypress trees are visible beyond the far wall enclosing the wheat field. Van Gogh telescoped the view in six of these paintings, most notably in F717 Wheat Field with Cypresses and The Starry Night, bringing the trees closer to the picture plane. One of the first paintings of the view was F611 Mountainous Landscape Behind Saint-Rémy, now in Copenhagen. Van Gogh made a number of sketches for the painting, of which F1547 The Enclosed Wheatfield After a Storm is typical. It is unclear whether the painting was made in his studio or outside. In his June 9 letter describing it, he mentions he had been working outside for a few days. Van Gogh described the second of the two landscapes he mentions he was working on, in a letter to his sister Wil on 16 June 1889. This is F719 Green Field, now in Prague, and the first painting at the asylum he definitely painted outside en plein air. F1548 Wheat field, Saint-Rémy de Provence, now in New York, is a study for it. Two days later, Vincent wrote Theo that he had painted a starry sky. The Starry Night is the only nocturne in the series of views from his bedroom window. In early June, Vincent wrote to Theo, This morning I saw the countryside from my window a long time before sunrise with nothing but the morning star, which looked very big Researchers have determined that Venus was indeed visible at dawn in Provence in the spring of 1889, and was at that time nearly as bright as possible. So the brightest star in the painting, just to the viewer's right of the cypress tree, is actually Venus. The Moon is stylized, as astronomical records indicate that it actually was waning gibbous at the time Van Gogh painted the picture, and even if the phase of the Moon had been its waning crescent at the time, Van Gogh's Moon would not have been astronomically correct. (For other interpretations of the Moon, see below.) The one pictorial element that was definitely not visible from Van Gogh's cell is the village, which is based on a sketch F1541v made from a hillside above the village of Saint-Rémy. Pickvance thought F1541v was done later, and the steeple more Dutch than Provençal, a conflation of several Van Gogh had painted and drawn in his Nuenen period, and thus the first of his reminisces of the North he was to paint and draw early the following year. Hulsker thought a landscape on the reverse F1541r was also a study for the painting."
        textView.sizeToFit()
//        // Make UITextView corners rounded
//        textView.layer.cornerRadius = 10
        
//        // Enable auto-correction and Spellcheck
//        textView.autocorrectionType = UITextAutocorrectionType.yes
//        textView.spellCheckingType = UITextSpellCheckingType.yes
//        // myTextView.autocapitalizationType = UITextAutocapitalizationType.None
//
//        // Make UITextView Editable
//        textView.isEditable = true
        
        self.view.addSubview(textView)
        
//        let textView = UITextView(frame: CGRect(origin: Me, size: <#T##CGSize#>))
//        
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenRect.width - 44, height: screenRect.height - 44))
//        label.center = CGPoint(x: screenRect.width / 2, y: screenRect.height / 2)
//        label.textAlignment = .center
//        label.text = "blablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdfblablavlalvbladlvmndjksbfkhjsbdfkjhbsdbfjbshfbsjbfsdfsbdbfjsbdfjbsdjfbjbfhdfbfjbjdfjdbskbdf"
//        label.textColor = UIColor.white
//        self.view.addSubview(label)
        
    }
    
    func layoutMenuView() {
        let path = UIBezierPath(ovalIn: CGRect(x: MenuView.frame.size.width/2 - MenuView.frame.size.height/2, y: 0.0, width:                MenuView.frame.size.height, height: MenuView.frame.size.height))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        MenuView.layer.mask = maskLayer
        MenuView.backgroundColor = UIColor.black
        MenuView.alpha = 0.9
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
