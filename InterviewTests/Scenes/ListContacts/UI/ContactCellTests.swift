import XCTest
import UIKit
@testable import Interview

final class ContactCellTests: XCTestCase {
    func test_identifier_returnsTypeName() {
        XCTAssertEqual(ContactCell.identifier, "ContactCell", "Should derive the reuse identifier from the type name")
    }

    func test_init_setsSelectionStyleToNone() {
        let sut = makeSut()

        XCTAssertEqual(sut.selectionStyle, .none, "Should disable the default selection highlight")
    }

    func test_init_addsContactImageAndFullnameLabelToContentView() {
        let sut = makeSut()

        XCTAssertTrue(sut.contentView.subviews.contains(sut.contactImage), "Should add the contact image to the content view")
        XCTAssertTrue(sut.contentView.subviews.contains(sut.fullnameLabel), "Should add the fullname label to the content view")
    }

    func test_init_disablesAutoresizingMaskForConstraintBasedLayout() {
        let sut = makeSut()

        XCTAssertFalse(sut.contactImage.translatesAutoresizingMaskIntoConstraints, "Should use Auto Layout for the contact image")
        XCTAssertFalse(sut.fullnameLabel.translatesAutoresizingMaskIntoConstraints, "Should use Auto Layout for the fullname label")
    }

    func test_init_configuresContactImageAsCircularAvatar() {
        let sut = makeSut()

        XCTAssertEqual(sut.contactImage.layer.cornerRadius, 50, "Should round the contact image into a circular avatar")
        XCTAssertTrue(sut.contactImage.clipsToBounds, "Should clip the contact image to its rounded bounds")
    }

    func test_init_startsWithNoImageOrText() {
        let sut = makeSut()

        XCTAssertNil(sut.contactImage.image, "Should start without a placeholder image")
        XCTAssertNil(sut.fullnameLabel.text, "Should start without a name")
    }

    func test_setup_setsFullnameLabelText() {
        let sut = makeSut()
        let contact = Contact.fixture(name: "Shakira")

        sut.setup(cell: contact)

        XCTAssertEqual(sut.fullnameLabel.text, "Shakira", "Should display the contact's name")
    }

    func test_setup_calledTwice_updatesFullnameLabelToLatestContact() {
        let sut = makeSut()

        sut.setup(cell: .fixture(name: "Zé"))
        sut.setup(cell: .fixture(name: "Ana"))

        XCTAssertEqual(sut.fullnameLabel.text, "Ana", "Should replace the previous name with the latest one")
    }

    func test_setup_whenPhotoURLIsEmpty_doesNotLoadAnImage() {
        let sut = makeSut()
        let contact = Contact.fixture(photoURL: "")

        sut.setup(cell: contact)

        XCTAssertNil(sut.contactImage.image, "Should not attempt to load an image for an invalid URL")
    }

    func test_prepareForReuse_clearsFullnameLabelAndContactImage() {
        let sut = makeSut()
        sut.setup(cell: .fixture(name: "Shakira", photoURL: ""))
        sut.contactImage.image = UIImage()

        sut.prepareForReuse()

        XCTAssertNil(sut.fullnameLabel.text, "Should clear the label so a reused cell doesn't flash stale content")
        XCTAssertNil(sut.contactImage.image, "Should clear the image so a reused cell doesn't flash stale content")
    }
}

extension ContactCellTests {
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> ContactCell {
        let sut = ContactCell(style: .default, reuseIdentifier: ContactCell.identifier)

        trackForMemoryLeaks(for: sut, file: file, line: line)

        return sut
    }
}
