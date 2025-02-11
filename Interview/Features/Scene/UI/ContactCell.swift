import UIKit

public final class ContactCell: UITableViewCell {
    static var identifier: String { String(describing: self) }
        
    private(set) lazy var contactImage: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 50
        imgView.accessibilityTraits = .updatesFrequently
        return imgView
    }()
    
    private(set) lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityTraits = .updatesFrequently
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureViews()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        contactImage.image = nil
        fullnameLabel.text = nil
    }
    
    required init?(coder: NSCoder) { nil }
    
    func setup(cell name: Contact) {
        fullnameLabel.text = name.name
        guard let imageURL = URL(string: name.photoURL) else { return }
        contactImage.load(urlImage: imageURL, mode: .scaleAspectFit)
    }
    
    func configureViews() {
        contentView.addSubview(contactImage)
        contentView.addSubview(fullnameLabel)
        NSLayoutConstraint.activate([
            contactImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            contactImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contactImage.heightAnchor.constraint(equalToConstant: 100),
            contactImage.widthAnchor.constraint(equalToConstant: 100),
            
            fullnameLabel.leadingAnchor.constraint(equalTo: contactImage.trailingAnchor, constant: 16),
            fullnameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            fullnameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            fullnameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
