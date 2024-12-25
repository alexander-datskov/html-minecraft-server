function handleError(response) {
    if (!response.ok) {
        throw new Error('Network response was not ok');
    }
    return response.json();
}

function displayError(message) {
    console.error('Error:', message);
    alert('Failed to process request. Please try again.');
}
