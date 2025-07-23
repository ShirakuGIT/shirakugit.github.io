// Global variables
let particles = [];
let mouse = { x: 0, y: 0 };
let canvas, ctx;
let isLoaded = false;

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Initialize loading screen
    initLoadingScreen();
    
    // Initialize particle system
    initParticleSystem();
    
    // Initialize custom cursor
    initCustomCursor();
    
    // Initialize smooth scrolling
    initSmoothScrolling();
    
    // Initialize navigation
    initNavigation();
    
    // Initialize scroll animations
    initScrollAnimations();
    
    // Initialize typing animation
    initTypingAnimation();
    
    // Initialize contact form
    initContactForm();
    
    // Initialize counter animations
    initCounterAnimations();
    
    // Initialize skill bars
    initSkillBars();
    
    // Initialize 3D hover effects
    init3DHoverEffects();
    
    // Initialize scroll progress
    initScrollProgress();
    
    // Initialize responsive handlers
    initResponsiveHandlers();
    
    // Initialize 3D shapes animation
    init3DShapes();
}

// Loading Screen
function initLoadingScreen() {
    const loadingScreen = document.getElementById('loadingScreen');
    
    // Simulate loading time
    setTimeout(() => {
        loadingScreen.classList.add('fade-out');
        isLoaded = true;
        
        // Start hero animations after loading
        setTimeout(() => {
            startHeroAnimations();
        }, 500);
    }, 2000);
}

// 3D Shapes Animation
function init3DShapes() {
    const shapes = document.querySelectorAll('.shape');
    
    shapes.forEach((shape, index) => {
        // Make shapes more visible and 3D
        shape.style.opacity = '0.8';
        shape.style.transition = 'all 0.3s ease';
        
        // Add mouse interaction
        document.addEventListener('mousemove', (e) => {
            const mouseX = e.clientX / window.innerWidth;
            const mouseY = e.clientY / window.innerHeight;
            
            const translateX = (mouseX - 0.5) * 50 * (index + 1);
            const translateY = (mouseY - 0.5) * 50 * (index + 1);
            const rotateX = (mouseY - 0.5) * 30;
            const rotateY = (mouseX - 0.5) * 30;
            
            shape.style.transform = `
                translate(${translateX}px, ${translateY}px) 
                rotateX(${45 + rotateX}deg) 
                rotateY(${45 + rotateY}deg)
                rotateZ(${index * 60}deg)
            `;
        });
    });
}

// Particle System
function initParticleSystem() {
    canvas = document.getElementById('particleCanvas');
    ctx = canvas.getContext('2d');
    
    resizeCanvas();
    createParticles();
    animateParticles();
    
    window.addEventListener('resize', resizeCanvas);
    document.addEventListener('mousemove', updateMousePosition);
}

function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

function updateMousePosition(e) {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
}

function createParticles() {
    const particleCount = window.innerWidth > 768 ? 60 : 30;
    particles = [];
    
    for (let i = 0; i < particleCount; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            vx: (Math.random() - 0.5) * 0.8,
            vy: (Math.random() - 0.5) * 0.8,
            size: Math.random() * 4 + 2,
            opacity: Math.random() * 0.6 + 0.3,
            originalOpacity: Math.random() * 0.6 + 0.3,
            connections: []
        });
    }
}

function animateParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Update and draw particles
    particles.forEach((particle, i) => {
        // Enhanced mouse attraction
        const dx = mouse.x - particle.x;
        const dy = mouse.y - particle.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        if (distance < 200) {
            const force = (200 - distance) / 200;
            particle.vx += dx * 0.0001 * force;
            particle.vy += dy * 0.0001 * force;
            
            // Make particles more visible when near mouse
            particle.opacity = Math.min(1, particle.originalOpacity + force * 0.5);
            particle.size = Math.min(6, particle.size + force * 2);
        } else {
            // Fade back to original values
            particle.opacity = particle.originalOpacity;
            particle.size = Math.max(2, particle.size - 0.1);
        }
        
        // Update position
        particle.x += particle.vx;
        particle.y += particle.vy;
        
        // Add friction
        particle.vx *= 0.99;
        particle.vy *= 0.99;
        
        // Bounce off edges with some damping
        if (particle.x < 0 || particle.x > canvas.width) {
            particle.vx *= -0.8;
            particle.x = Math.max(0, Math.min(canvas.width, particle.x));
        }
        if (particle.y < 0 || particle.y > canvas.height) {
            particle.vy *= -0.8;
            particle.y = Math.max(0, Math.min(canvas.height, particle.y));
        }
        
        // Draw particle with glow effect
        ctx.save();
        ctx.globalAlpha = particle.opacity;
        
        // Glow effect
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.size + 2, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(50, 184, 198, ${particle.opacity * 0.3})`;
        ctx.fill();
        
        // Main particle
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(33, 128, 141, ${particle.opacity})`;
        ctx.fill();
        
        ctx.restore();
        
        // Draw connections with enhanced visibility
        particles.slice(i + 1).forEach(otherParticle => {
            const dx = particle.x - otherParticle.x;
            const dy = particle.y - otherParticle.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            
            if (distance < 120) {
                const opacity = 0.4 * (120 - distance) / 120;
                ctx.beginPath();
                ctx.moveTo(particle.x, particle.y);
                ctx.lineTo(otherParticle.x, otherParticle.y);
                ctx.strokeStyle = `rgba(33, 128, 141, ${opacity})`;
                ctx.lineWidth = 1.5;
                ctx.stroke();
            }
        });
    });
    
    requestAnimationFrame(animateParticles);
}

// Custom Cursor
function initCustomCursor() {
    if (window.innerWidth <= 768) return; // Skip on mobile
    
    const cursor = document.getElementById('cursor');
    const cursorTrail = document.getElementById('cursorTrail');
    
    let cursorX = 0, cursorY = 0;
    let trailX = 0, trailY = 0;
    
    document.addEventListener('mousemove', (e) => {
        cursorX = e.clientX;
        cursorY = e.clientY;
    });
    
    function animateCursor() {
        cursor.style.left = cursorX + 'px';
        cursor.style.top = cursorY + 'px';
        
        trailX += (cursorX - trailX) * 0.1;
        trailY += (cursorY - trailY) * 0.1;
        
        cursorTrail.style.left = trailX + 'px';
        cursorTrail.style.top = trailY + 'px';
        
        requestAnimationFrame(animateCursor);
    }
    
    animateCursor();
    
    // Cursor hover effects
    const hoverElements = document.querySelectorAll('a, button, .nav-item, .project-card, .social-link');
    
    hoverElements.forEach(element => {
        element.addEventListener('mouseenter', () => {
            cursor.style.width = '40px';
            cursor.style.height = '40px';
        });
        
        element.addEventListener('mouseleave', () => {
            cursor.style.width = '20px';
            cursor.style.height = '20px';
        });
    });
}

// Smooth Scrolling
function initSmoothScrolling() {
    // Basic smooth scrolling implementation
    const links = document.querySelectorAll('.nav-item');
    
    links.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const targetId = link.getAttribute('data-section');
            const targetSection = document.getElementById(targetId);
            
            if (targetSection) {
                targetSection.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Navigation
function initNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const sections = document.querySelectorAll('section[id]');
    
    navItems.forEach(item => {
        item.addEventListener('click', (e) => {
            const targetSection = e.currentTarget.dataset.section;
            const targetElement = document.getElementById(targetSection);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Update active nav item on scroll
    function updateActiveNavItem() {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            
            if (window.pageYOffset >= sectionTop - 200) {
                current = section.getAttribute('id');
            }
        });
        
        navItems.forEach(item => {
            item.classList.remove('active');
            if (item.dataset.section === current) {
                item.classList.add('active');
            }
        });
    }
    
    window.addEventListener('scroll', updateActiveNavItem);
}

// Scroll Animations
function initScrollAnimations() {
    const animatedElements = document.querySelectorAll('[data-aos]');
    
    function checkAnimations() {
        animatedElements.forEach(element => {
            const elementTop = element.getBoundingClientRect().top;
            const elementVisible = 150;
            
            if (elementTop < window.innerHeight - elementVisible) {
                element.classList.add('animate');
            }
        });
    }
    
    // Timeline specific animations
    const timelineItems = document.querySelectorAll('.timeline-item');
    
    function checkTimelineAnimations() {
        timelineItems.forEach((item, index) => {
            const elementTop = item.getBoundingClientRect().top;
            const elementVisible = 150;
            
            if (elementTop < window.innerHeight - elementVisible) {
                setTimeout(() => {
                    item.classList.add('animate');
                }, index * 200);
            }
        });
    }
    
    function handleScroll() {
        checkAnimations();
        checkTimelineAnimations();
    }
    
    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Check on load
}

// Typing Animation
function initTypingAnimation() {
    const words = document.querySelectorAll('.hero-title .word');
    
    function animateWord(word, delay) {
        setTimeout(() => {
            const text = word.dataset.text;
            word.textContent = '';
            word.style.opacity = '1';
            
            let i = 0;
            const typeInterval = setInterval(() => {
                word.textContent += text[i];
                i++;
                
                if (i >= text.length) {
                    clearInterval(typeInterval);
                }
            }, 100);
        }, delay);
    }
    
    words.forEach((word, index) => {
        animateWord(word, index * 800 + 1000);
    });
}

// Hero Animations
function startHeroAnimations() {
    // Animate floating shapes
    const shapes = document.querySelectorAll('.shape');
    shapes.forEach((shape, index) => {
        setTimeout(() => {
            shape.style.opacity = '0.8';
            shape.style.animation = `float 6s ease-in-out infinite ${index * -2}s`;
        }, index * 300);
    });
}

// Contact Form - FIXED
function initContactForm() {
    const form = document.getElementById('contactForm');
    const submitBtn = document.getElementById('submitBtn');
    
    if (!form || !submitBtn) return;
    
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        // Show loading state
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
        
        try {
            // Simulate form submission with actual delay
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Remove loading state
            submitBtn.classList.remove('loading');
            submitBtn.disabled = false;
            
            // Show success message
            showNotification('Message sent successfully! I\'ll get back to you soon.', 'success');
            
            // Reset form
            form.reset();
            
        } catch (error) {
            // Remove loading state
            submitBtn.classList.remove('loading');
            submitBtn.disabled = false;
            
            // Show error message
            showNotification('Failed to send message. Please try again.', 'error');
        }
    });
}

// Counter Animations
function initCounterAnimations() {
    const counters = document.querySelectorAll('.stat-number');
    let hasAnimated = false;
    
    function animateCounters() {
        if (hasAnimated) return;
        
        const heroSection = document.getElementById('hero');
        const heroBottom = heroSection.getBoundingClientRect().bottom;
        
        if (heroBottom < window.innerHeight) {
            hasAnimated = true;
            
            counters.forEach(counter => {
                const target = parseInt(counter.dataset.count);
                let current = 0;
                const increment = target / 50;
                
                const timer = setInterval(() => {
                    current += increment;
                    
                    if (current >= target) {
                        current = target;
                        clearInterval(timer);
                    }
                    
                    counter.textContent = Math.floor(current);
                }, 40);
            });
        }
    }
    
    window.addEventListener('scroll', animateCounters);
}

// Skill Bars Animation
function initSkillBars() {
    const skillBars = document.querySelectorAll('.skill-progress');
    let hasAnimated = false;
    
    function animateSkillBars() {
        if (hasAnimated) return;
        
        const skillsSection = document.getElementById('skills');
        if (!skillsSection) return;
        
        const skillsTop = skillsSection.getBoundingClientRect().top;
        
        if (skillsTop < window.innerHeight - 200) {
            hasAnimated = true;
            
            skillBars.forEach((bar, index) => {
                setTimeout(() => {
                    const width = bar.dataset.width;
                    bar.style.width = width;
                }, index * 200);
            });
        }
    }
    
    window.addEventListener('scroll', animateSkillBars);
}

// 3D Hover Effects
function init3DHoverEffects() {
    const cards = document.querySelectorAll('.glass-card, .project-card');
    
    cards.forEach(card => {
        card.addEventListener('mouseenter', (e) => {
            card.style.transformStyle = 'preserve-3d';
        });
        
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 10;
            const rotateY = (centerX - x) / 10;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateZ(10px)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) translateZ(0px)';
        });
    });
    
    // Rotating skills interaction
    const rotatingSkills = document.querySelectorAll('.rotating-skill');
    
    rotatingSkills.forEach(skill => {
        skill.addEventListener('mouseenter', () => {
            skill.style.animationPlayState = 'paused';
        });
        
        skill.addEventListener('mouseleave', () => {
            skill.style.animationPlayState = 'running';
        });
        
        skill.addEventListener('click', () => {
            const skillName = skill.dataset.skill;
            showNotification(`${skillName} - Technology expertise in robotics!`, 'info');
        });
    });
}

// Scroll Progress
function initScrollProgress() {
    const progressBar = document.getElementById('scrollProgress');
    if (!progressBar) return;
    
    function updateScrollProgress() {
        const scrollTop = window.pageYOffset;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrollPercent = scrollTop / docHeight;
        
        progressBar.style.transform = `scaleX(${Math.max(0, Math.min(1, scrollPercent))})`;
    }
    
    window.addEventListener('scroll', updateScrollProgress);
}

// Responsive Handlers
function initResponsiveHandlers() {
    let resizeTimeout;
    
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(() => {
            // Recreate particles with new count
            createParticles();
            
            // Update canvas size
            resizeCanvas();
        }, 250);
    });
}

// Utility Functions - FIXED NOTIFICATION SYSTEM
function showNotification(message, type = 'info') {
    // Remove any existing notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(notification => notification.remove());
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    // Set up notification styles
    const baseStyles = {
        position: 'fixed',
        top: '20px',
        right: '20px',
        padding: '16px 24px',
        borderRadius: '12px',
        fontWeight: '500',
        fontSize: '14px',
        zIndex: '10000',
        transform: 'translateX(400px)',
        transition: 'all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55)',
        maxWidth: '350px',
        wordWrap: 'break-word',
        backdropFilter: 'blur(20px)',
        border: '1px solid rgba(255, 255, 255, 0.2)',
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)'
    };
    
    // Type-specific styling
    let typeStyles = {};
    switch (type) {
        case 'success':
            typeStyles = {
                background: 'rgba(33, 128, 141, 0.15)',
                color: '#1d8086',
                borderLeft: '4px solid #21808d'
            };
            message = '✅ ' + message;
            break;
        case 'error':
            typeStyles = {
                background: 'rgba(192, 21, 47, 0.15)',
                color: '#c0152f',
                borderLeft: '4px solid #c0152f'
            };
            message = '❌ ' + message;
            break;
        case 'info':
        default:
            typeStyles = {
                background: 'rgba(98, 108, 113, 0.15)',
                color: '#626c71',
                borderLeft: '4px solid #626c71'
            };
            message = 'ℹ️ ' + message;
            break;
    }
    
    // Apply all styles
    Object.assign(notification.style, baseStyles, typeStyles);
    notification.textContent = message;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Force reflow and animate in
    notification.offsetHeight;
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 10);
    
    // Auto remove after delay
    setTimeout(() => {
        notification.style.transform = 'translateX(400px)';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 400);
    }, 4000);
    
    console.log(`Notification shown: ${message} (${type})`); // Debug log
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Enhanced scroll-triggered animations
function initEnhancedScrollAnimations() {
    // Parallax effect for floating shapes
    const shapes = document.querySelectorAll('.shape');
    
    function updateParallax() {
        const scrolled = window.pageYOffset;
        const rate = scrolled * -0.3;
        
        shapes.forEach((shape, index) => {
            const speed = (index + 1) * 0.2;
            const currentTransform = shape.style.transform || '';
            
            // Preserve existing transforms and add parallax
            if (currentTransform.includes('translate(')) {
                // Keep existing mouse-based transforms
                return;
            }
            
            shape.style.transform = `translateY(${rate * speed}px) rotateX(45deg) rotateY(45deg) rotateZ(${index * 60}deg)`;
        });
    }
    
    window.addEventListener('scroll', debounce(updateParallax, 16));
}

// Initialize enhanced features
document.addEventListener('DOMContentLoaded', () => {
    setTimeout(() => {
        initEnhancedScrollAnimations();
    }, 1000);
});

// Performance optimization
function optimizeForMobile() {
    if (window.innerWidth <= 768) {
        // Reduce particle count on mobile
        if (particles.length > 25) {
            particles = particles.slice(0, 25);
        }
        
        // Simplify animations on mobile
        document.querySelectorAll('.rotating-skill').forEach(skill => {
            skill.style.position = 'static';
            skill.style.animation = 'none';
            skill.style.margin = '8px';
        });
    }
}

// Call optimization on load and resize
window.addEventListener('load', optimizeForMobile);
window.addEventListener('resize', debounce(optimizeForMobile, 250));