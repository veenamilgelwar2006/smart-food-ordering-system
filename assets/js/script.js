/* =====================================================
   Smart Canteen - JavaScript Functions
   ===================================================== */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips
    initializeTooltips();
    
    // Add to cart functionality
    setupCartFunctionality();
    
    // Setup search filters
    setupSearchFilters();
});

// Initialize Bootstrap tooltips
function initializeTooltips() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

// Setup shopping cart functionality
function setupCartFunctionality() {
    const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');
    
    addToCartButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const menuItemId = this.dataset.menuItemId;
            const foodName = this.dataset.foodName;
            const price = parseFloat(this.dataset.price);
            
            addToCart(menuItemId, foodName, price);
        });
    });
}

// Add item to cart
function addToCart(menuItemId, foodName, price) {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    
    // Check if item already exists in cart
    const existingItem = cart.find(item => item.menuItemId === parseInt(menuItemId));
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            menuItemId: parseInt(menuItemId),
            foodName: foodName,
            price: price,
            quantity: 1
        });
    }
    
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    showNotification('Item added to cart!', 'success');
}

// Remove item from cart
function removeFromCart(menuItemId) {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    cart = cart.filter(item => item.menuItemId !== parseInt(menuItemId));
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    displayCart();
}

// Update cart item quantity
function updateCartQuantity(menuItemId, quantity) {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    const item = cart.find(item => item.menuItemId === parseInt(menuItemId));
    
    if (item) {
        if (quantity <= 0) {
            removeFromCart(menuItemId);
        } else {
            item.quantity = quantity;
            localStorage.setItem('cart', JSON.stringify(cart));
            displayCart();
        }
    }
}

// Update cart count in navbar
function updateCartCount() {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    
    const cartCountElements = document.querySelectorAll('.cart-count');
    cartCountElements.forEach(el => {
        el.textContent = totalItems;
    });
}

// Display cart items
function displayCart() {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    const cartContainer = document.getElementById('cart-items');
    
    if (!cartContainer) return;
    
    if (cart.length === 0) {
        cartContainer.innerHTML = '<p class="text-center text-muted">Your cart is empty</p>';
        updateCartTotal();
        return;
    }
    
    cartContainer.innerHTML = '';
    
    cart.forEach(item => {
        const cartItem = document.createElement('div');
        cartItem.className = 'cart-item';
        cartItem.innerHTML = `
            <div class="flex-grow-1">
                <h6>${item.foodName}</h6>
                <p class="text-muted mb-0">₹${item.price.toFixed(2)} x ${item.quantity}</p>
            </div>
            <div class="input-group input-group-sm" style="width: 100px;">
                <button class="btn btn-outline-secondary" onclick="updateCartQuantity(${item.menuItemId}, ${item.quantity - 1})">-</button>
                <input type="text" class="form-control text-center" value="${item.quantity}" readonly>
                <button class="btn btn-outline-secondary" onclick="updateCartQuantity(${item.menuItemId}, ${item.quantity + 1})">+</button>
            </div>
            <button class="btn btn-sm btn-danger ms-2" onclick="removeFromCart(${item.menuItemId})">
                <i class="fas fa-trash"></i>
            </button>
        `;
        cartContainer.appendChild(cartItem);
    });
    
    updateCartTotal();
}

// Update cart total
function updateCartTotal() {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    const totalElement = document.getElementById('cart-total');
    if (totalElement) {
        totalElement.textContent = total.toFixed(2);
    }
}

// Setup search and filter functionality
function setupSearchFilters() {
    const searchInput = document.getElementById('search-food');
    const filterButtons = document.querySelectorAll('.filter-category');
    
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            filterMenuItems();
        });
    }
    
    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            filterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            filterMenuItems();
        });
    });
}

// Filter menu items
function filterMenuItems() {
    const searchInput = document.getElementById('search-food');
    const activeCategory = document.querySelector('.filter-category.active');
    const menuItems = document.querySelectorAll('.menu-item-card');
    
    const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
    const categoryFilter = activeCategory ? activeCategory.dataset.category : 'all';
    
    menuItems.forEach(item => {
        const foodName = item.dataset.foodName.toLowerCase();
        const category = item.dataset.category;
        
        const matchesSearch = foodName.includes(searchTerm);
        const matchesCategory = categoryFilter === 'all' || category === categoryFilter;
        
        if (matchesSearch && matchesCategory) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}

// Show notification
function showNotification(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    setTimeout(() => {
        alertDiv.remove();
    }, 3000);
}

// Format currency
function formatCurrency(amount) {
    return '₹' + parseFloat(amount).toFixed(2);
}

// Format date
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
    return new Date(dateString).toLocaleDateString('en-IN', options);
}

// Validate email
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// Validate phone number
function validatePhone(phone) {
    const re = /^[0-9]{10}$/;
    return re.test(phone);
}

// Clear cart
function clearCart() {
    if (confirm('Are you sure you want to clear your cart?')) {
        localStorage.removeItem('cart');
        updateCartCount();
        displayCart();
        showNotification('Cart cleared', 'info');
    }
}

// Initialize on page load
window.addEventListener('load', function() {
    updateCartCount();
    displayCart();
});
