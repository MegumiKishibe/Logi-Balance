const buttonAdd = document.getElementById('button-add');
const list = document.getElementById('list');
const selectDestinations = document.getElementById('select-destinations');
const selectPackages = document.getElementById('select-packages');
const selectPieces = document.getElementById('select-pieces');

buttonAdd.addEventListener('click', function() {
    const numDestinations = selectDestinations.selectedIndex; // Get the index of the selected option
    const getDestination = selectDestinations.options[numDestinations].text; // Get the text of the selected option

    const numPackages = selectPackages.selectedIndex;
    const getPackage = selectPackages.options[numPackages].text;

    const numPieces = selectPieces.selectedIndex;
    const getPiece = selectPieces.options[numPieces].text;

    const text = `${getDestination} - ${getPackage} - ${getPiece}`; // 並べたい順で１つの文字列にする

    // Create a new list item and append it to the list
    const newList = document.createElement('li');
    newList.textContent = text;
    list.appendChild(newList);
});