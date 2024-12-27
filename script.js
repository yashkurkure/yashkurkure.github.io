const catImg = document.getElementById('cat-img');

document.addEventListener('mousemove', (event) => {
    const mouseX = event.clientX;
    const mouseY = event.clientY;

    // Use transform for smoother movement
    catImg.style.transform = `translate(${mouseX}px, ${mouseY}px)`;
});