// Portfolio Website JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // DOM Elements
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    const navLinks = document.querySelectorAll('.nav__link');
    const header = document.querySelector('.header');
    const sections = document.querySelectorAll('section[id]');

    // Ensure elements exist before adding event listeners
    console.log('Navigation elements:', {
        navToggle: !!navToggle,
        navMenu: !!navMenu,
        navLinks: navLinks.length,
        header: !!header,
        sections: sections.length
    });

    // Mobile Navigation Toggle
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            console.log('Nav toggle clicked');
            
            navMenu.classList.toggle('show-menu');
            navToggle.classList.toggle('toggle-active');
            
            // Prevent body scrolling when menu is open
            if (navMenu.classList.contains('show-menu')) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        });
    }

    // Close mobile menu when clicking on a link
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            console.log('Nav link clicked:', this.getAttribute('href'));
            
            // Close mobile menu
            if (navMenu) {
                navMenu.classList.remove('show-menu');
            }
            if (navToggle) {
                navToggle.classList.remove('toggle-active');
            }
            document.body.style.overflow = '';
            
            // Handle smooth scrolling
            const targetId = this.getAttribute('href');
            if (targetId && targetId.startsWith('#')) {
                e.preventDefault();
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    const headerHeight = header ? header.offsetHeight : 70;
                    const targetPosition = targetElement.offsetTop - headerHeight;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        if (!navToggle || !navMenu) return;
        
        const isNavToggle = navToggle.contains(event.target);
        const isNavMenu = navMenu.contains(event.target);
        
        if (!isNavToggle && !isNavMenu && navMenu.classList.contains('show-menu')) {
            navMenu.classList.remove('show-menu');
            navToggle.classList.remove('toggle-active');
            document.body.style.overflow = '';
        }
    });

    // Header scroll effect
    function handleScroll() {
        if (!header) return;
        
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > 50) {
            header.classList.add('scroll-header');
        } else {
            header.classList.remove('scroll-header');
        }

        // Update active navigation link
        updateActiveNavLink();
    }

    // Update active navigation link based on scroll position
    function updateActiveNavLink() {
        const scrollPos = window.pageYOffset + 100;

        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.offsetHeight;
            const sectionId = section.getAttribute('id');
            const correspondingLink = document.querySelector(`.nav__link[href="#${sectionId}"]`);

            if (scrollPos >= sectionTop && scrollPos < sectionTop + sectionHeight) {
                // Remove active class from all links
                navLinks.forEach(link => link.classList.remove('active-link'));
                
                // Add active class to current section link
                if (correspondingLink) {
                    correspondingLink.classList.add('active-link');
                }
            }
        });
    }

    // Handle button clicks for smooth scrolling
    const heroButtons = document.querySelectorAll('.hero__buttons .btn');
    heroButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href && href.startsWith('#')) {
                e.preventDefault();
                const targetElement = document.querySelector(href);
                if (targetElement) {
                    const headerHeight = header ? header.offsetHeight : 70;
                    const targetPosition = targetElement.offsetTop - headerHeight;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                }
            }
        });
    });

    // Scroll event listener with throttling
    let scrollTimeout;
    function throttledScroll() {
        if (scrollTimeout) return;
        scrollTimeout = setTimeout(() => {
            handleScroll();
            scrollTimeout = null;
        }, 16); // ~60fps
    }

    window.addEventListener('scroll', throttledScroll, { passive: true });

    // Initialize on page load
    handleScroll();

    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe all sections for animation
    sections.forEach(section => {
        section.style.opacity = '0';
        section.style.transform = 'translateY(30px)';
        section.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
        observer.observe(section);
    });

    // Observe cards and other elements for staggered animation
    const animateElements = document.querySelectorAll('.card, .experience__item, .project__card, .award__item');
    
    animateElements.forEach((element, index) => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(30px)';
        element.style.transition = `opacity 0.6s ease-out ${index * 0.1}s, transform 0.6s ease-out ${index * 0.1}s`;
        observer.observe(element);
    });

    // Hero section typing effect for the name
    const heroName = document.querySelector('.hero__name');
    if (heroName) {
        const originalText = heroName.textContent;
        heroName.textContent = '';
        heroName.style.borderRight = '2px solid var(--color-primary)';
        
        let index = 0;
        const typeWriter = () => {
            if (index < originalText.length) {
                heroName.textContent += originalText.charAt(index);
                index++;
                setTimeout(typeWriter, 50);
            } else {
                // Remove cursor after typing is complete
                setTimeout(() => {
                    heroName.style.borderRight = 'none';
                }, 1000);
            }
        };
        
        // Start typing effect after a short delay
        setTimeout(typeWriter, 1000);
    }

    // Add hover effects to skill tags
    const skillTags = document.querySelectorAll('.skill-tag');
    skillTags.forEach(tag => {
        tag.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px) scale(1.05)';
        });
        
        tag.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });

    // Add click effect to tech tags
    const techTags = document.querySelectorAll('.tech-tag');
    techTags.forEach(tag => {
        tag.addEventListener('click', function() {
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
        });
    });

    // Enhanced email functionality
    const emailLinks = document.querySelectorAll('a[href^="mailto:"]');
    emailLinks.forEach(emailLink => {
        emailLink.addEventListener('click', function(e) {
            const email = this.getAttribute('href').replace('mailto:', '');
            
            // Try to copy to clipboard if supported
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(email).then(() => {
                    showNotification('Email copied to clipboard!');
                }).catch(() => {
                    // Fallback: just show the email
                    showNotification(`Email: ${email}`);
                });
            } else {
                // Fallback for older browsers
                showNotification(`Email: ${email}`);
            }
            
            // Allow default email client to open
            return true;
        });
    });

    // Enhanced social media links
    const socialLinks = document.querySelectorAll('a[target="_blank"]');
    socialLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const platform = this.getAttribute('aria-label') || this.textContent;
            showNotification(`Opening ${platform}...`);
            
            // Add loading state
            const originalText = this.textContent;
            this.style.opacity = '0.7';
            
            setTimeout(() => {
                this.style.opacity = '1';
            }, 1000);
        });
    });

    // Show notification function
    function showNotification(message) {
        // Remove existing notifications
        const existingNotifications = document.querySelectorAll('.notification');
        existingNotifications.forEach(notification => {
            notification.remove();
        });

        const notification = document.createElement('div');
        notification.className = 'notification';
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--color-success);
            color: var(--color-btn-primary-text);
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            z-index: 9999;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transform: translateX(100%);
            transition: transform 0.3s ease;
            max-width: 300px;
        `;
        
        document.body.appendChild(notification);
        
        // Animate in
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 100);
        
        // Remove after delay
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }

    // Add smooth reveal for contact items
    const contactItems = document.querySelectorAll('.contact__item');
    contactItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateY(20px)';
        item.style.transition = `opacity 0.5s ease ${index * 0.1}s, transform 0.5s ease ${index * 0.1}s`;
        observer.observe(item);
    });

    // Add keyboard navigation support
    document.addEventListener('keydown', function(e) {
        // ESC key closes mobile menu
        if (e.key === 'Escape' && navMenu && navMenu.classList.contains('show-menu')) {
            navMenu.classList.remove('show-menu');
            if (navToggle) {
                navToggle.classList.remove('toggle-active');
            }
            document.body.style.overflow = '';
        }
        
        // Arrow keys for navigation
        if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
            e.preventDefault();
            const currentActive = document.querySelector('.nav__link.active-link');
            const allNavLinks = Array.from(navLinks);
            const currentIndex = allNavLinks.indexOf(currentActive);
            
            let nextIndex;
            if (e.key === 'ArrowUp') {
                nextIndex = currentIndex > 0 ? currentIndex - 1 : allNavLinks.length - 1;
            } else {
                nextIndex = currentIndex < allNavLinks.length - 1 ? currentIndex + 1 : 0;
            }
            
            if (nextIndex >= 0 && nextIndex < allNavLinks.length) {
                allNavLinks[nextIndex].click();
            }
        }
    });

    // Add scroll-to-top functionality
    const scrollToTop = document.createElement('button');
    scrollToTop.innerHTML = '↑';
    scrollToTop.setAttribute('aria-label', 'Scroll to top');
    scrollToTop.style.cssText = `
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 50px;
        height: 50px;
        border: none;
        border-radius: 50%;
        background: var(--color-primary);
        color: var(--color-btn-primary-text);
        font-size: 20px;
        font-weight: bold;
        cursor: pointer;
        z-index: 1000;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        transition: all 0.3s ease;
        opacity: 0;
        transform: translateY(100px);
    `;
    
    document.body.appendChild(scrollToTop);
    
    scrollToTop.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
    
    // Show/hide scroll-to-top button
    function updateScrollToTop() {
        if (window.pageYOffset > 300) {
            scrollToTop.style.opacity = '1';
            scrollToTop.style.transform = 'translateY(0)';
        } else {
            scrollToTop.style.opacity = '0';
            scrollToTop.style.transform = 'translateY(100px)';
        }
    }
    
    window.addEventListener('scroll', updateScrollToTop, { passive: true });

    // Add resize event listener for responsive adjustments
    window.addEventListener('resize', function() {
        if (window.innerWidth > 1024) {
            if (navMenu) {
                navMenu.classList.remove('show-menu');
            }
            if (navToggle) {
                navToggle.classList.remove('toggle-active');
            }
            document.body.style.overflow = '';
        }
    });

    // Add loading animation for the page
    window.addEventListener('load', function() {
        document.body.style.opacity = '1';
        document.body.style.transition = 'opacity 0.5s ease';
    });

    // Set initial body opacity
    document.body.style.opacity = '0';

    // Preload critical images
    const heroImage = document.querySelector('.hero__img');
    if (heroImage) {
        const img = new Image();
        img.onload = function() {
            heroImage.style.opacity = '1';
        };
        img.src = heroImage.src;
        heroImage.style.opacity = '0';
        heroImage.style.transition = 'opacity 0.5s ease';
    }

    // Add error handling for missing images
    const images = document.querySelectorAll('img');
    images.forEach(img => {
        img.addEventListener('error', function() {
            console.warn('Image failed to load:', this.src);
            this.style.display = 'none';
        });
    });

    // Console message for developers
    console.log('🤖 Welcome to Shivaram Kumar Jagannathan\'s Portfolio!');
    console.log('🚀 Robotics Engineer & Researcher');
    console.log('💻 Built with HTML, CSS, and JavaScript');
    console.log('🔗 Contact: shivaram.jagannathan@outlook.com');
    console.log('📱 Mobile navigation:', !!navToggle && !!navMenu);
});

// Analytics helper functions (placeholder for future implementation)
function trackEvent(eventName, eventData) {
    // Placeholder for analytics tracking
    console.log(`Event: ${eventName}`, eventData);
}

// Track important interactions
document.addEventListener('click', function(e) {
    const target = e.target;
    
    if (target.matches('.btn--primary')) {
        trackEvent('button_click', { button: 'primary', text: target.textContent });
    }
    
    if (target.matches('.hero__social-link')) {
        trackEvent('social_link_click', { platform: target.getAttribute('aria-label') });
    }
    
    if (target.matches('.contact__link')) {
        trackEvent('contact_link_click', { type: target.getAttribute('href') });
    }
});

// Error handling for missing elements
function safeQuerySelector(selector) {
    const element = document.querySelector(selector);
    if (!element) {
        console.warn(`Element not found: ${selector}`);
    }
    return element;
}

// Utility function for smooth animations
function animateElement(element, properties, duration = 300) {
    if (!element) return;
    
    const startTime = Date.now();
    const startValues = {};
    
    // Get initial values
    Object.keys(properties).forEach(prop => {
        startValues[prop] = parseFloat(getComputedStyle(element)[prop]) || 0;
    });
    
    function animate() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function (ease-out)
        const easeOut = 1 - Math.pow(1 - progress, 3);
        
        Object.keys(properties).forEach(prop => {
            const start = startValues[prop];
            const end = properties[prop];
            const current = start + (end - start) * easeOut;
            
            element.style[prop] = current + (prop.includes('opacity') ? '' : 'px');
        });
        
        if (progress < 1) {
            requestAnimationFrame(animate);
        }
    }
    
    requestAnimationFrame(animate);
}

// Service Worker registration for offline functionality (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js')
            .then(function(registration) {
                console.log('ServiceWorker registration successful');
            })
            .catch(function(error) {
                console.log('ServiceWorker registration failed:', error);
            });
    });
}