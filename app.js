// Modern Portfolio JavaScript with Advanced Animations and Interactions

class PortfolioApp {
  constructor() {
    this.init();
  }

  init() {
    this.setupNavigation();
    this.setupParticles();
    this.setupTypewriter();
    this.setupScrollAnimations();
    this.setupCounterAnimations();
    this.setupFormHandling();
    this.setupSmoothScroll();
    this.setupParallax();
  }

  // Navigation Management
  setupNavigation() {
    const nav = document.getElementById('nav');
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');
    const navLinks = document.querySelectorAll('.nav__link');

    // Mobile menu toggle
    navToggle?.addEventListener('click', () => {
      navMenu.classList.toggle('active');
      navToggle.classList.toggle('active');
    });

    // Close mobile menu when clicking on a link
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        navToggle.classList.remove('active');
      });
    });

    // Navbar scroll effect
    let lastScrollTop = 0;
    window.addEventListener('scroll', () => {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      
      if (scrollTop > 100) {
        nav.classList.add('scrolled');
      } else {
        nav.classList.remove('scrolled');
      }

      // Update active navigation link
      this.updateActiveNavLink();
      
      lastScrollTop = scrollTop;
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!nav.contains(e.target)) {
        navMenu.classList.remove('active');
        navToggle.classList.remove('active');
      }
    });
  }

  updateActiveNavLink() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav__link');
    
    let current = '';
    const scrollY = window.pageYOffset;

    sections.forEach(section => {
      const sectionHeight = section.offsetHeight;
      const sectionTop = section.offsetTop - 100;
      const sectionId = section.getAttribute('id');

      if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
        current = sectionId;
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
      }
    });
  }

  // Particle Animation System
  setupParticles() {
    const canvas = document.getElementById('particles-canvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    let particles = [];
    let animationId;

    // Resize canvas
    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    // Particle class
    class Particle {
      constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * 3 + 1;
        this.speedX = Math.random() * 2 - 1;
        this.speedY = Math.random() * 2 - 1;
        this.opacity = Math.random() * 0.5 + 0.2;
        this.color = `rgba(102, 126, 234, ${this.opacity})`;
      }

      update() {
        this.x += this.speedX;
        this.y += this.speedY;

        // Bounce off edges
        if (this.x > canvas.width || this.x < 0) {
          this.speedX = -this.speedX;
        }
        if (this.y > canvas.height || this.y < 0) {
          this.speedY = -this.speedY;
        }

        // Pulsate
        this.opacity += (Math.random() - 0.5) * 0.02;
        this.opacity = Math.max(0.1, Math.min(0.8, this.opacity));
        this.color = `rgba(102, 126, 234, ${this.opacity})`;
      }

      draw() {
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    // Initialize particles
    const createParticles = () => {
      particles = [];
      const particleCount = Math.min(100, Math.floor(canvas.width * canvas.height / 10000));
      
      for (let i = 0; i < particleCount; i++) {
        particles.push(new Particle());
      }
    };

    // Animation loop
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      // Update and draw particles
      particles.forEach(particle => {
        particle.update();
        particle.draw();
      });

      // Draw connections
      this.drawConnections(particles, ctx, canvas);

      animationId = requestAnimationFrame(animate);
    };

    // Mouse interaction
    let mouse = { x: null, y: null, radius: 100 };
    
    canvas.addEventListener('mousemove', (e) => {
      mouse.x = e.x;
      mouse.y = e.y;
    });

    canvas.addEventListener('mouseleave', () => {
      mouse.x = null;
      mouse.y = null;
    });

    // Initialize
    resizeCanvas();
    createParticles();
    animate();

    // Handle window resize
    window.addEventListener('resize', () => {
      resizeCanvas();
      createParticles();
    });

    // Cleanup
    window.addEventListener('beforeunload', () => {
      cancelAnimationFrame(animationId);
    });
  }

  drawConnections(particles, ctx, canvas) {
    for (let a = 0; a < particles.length; a++) {
      for (let b = a + 1; b < particles.length; b++) {
        const dx = particles[a].x - particles[b].x;
        const dy = particles[a].y - particles[b].y;
        const distance = Math.sqrt(dx * dx + dy * dy);

        if (distance < 100) {
          const opacity = 1 - distance / 100;
          ctx.strokeStyle = `rgba(102, 126, 234, ${opacity * 0.2})`;
          ctx.lineWidth = 1;
          ctx.beginPath();
          ctx.moveTo(particles[a].x, particles[a].y);
          ctx.lineTo(particles[b].x, particles[b].y);
          ctx.stroke();
        }
      }
    }
  }

  // Typewriter Effect
  setupTypewriter() {
    const typingElement = document.getElementById('typing-text');
    if (!typingElement) return;

    const texts = [
      'Shivaram Kumar Jagannathan',
      'Robotics Engineer',
      'AI Researcher',
      'Innovation Leader'
    ];
    
    let textIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    let isPaused = false;

    const typeWriter = () => {
      const currentText = texts[textIndex];
      const cursor = document.querySelector('.cursor');

      if (!isDeleting) {
        typingElement.textContent = currentText.slice(0, charIndex + 1);
        charIndex++;

        if (charIndex === currentText.length) {
          isPaused = true;
          setTimeout(() => {
            isPaused = false;
            isDeleting = true;
          }, 2000); // Pause before deleting
        }
      } else {
        typingElement.textContent = currentText.slice(0, charIndex);
        charIndex--;

        if (charIndex === 0) {
          isDeleting = false;
          textIndex = (textIndex + 1) % texts.length;
        }
      }

      if (!isPaused) {
        const speed = isDeleting ? 50 : 100;
        setTimeout(typeWriter, speed + Math.random() * 100);
      } else {
        setTimeout(typeWriter, 100);
      }
    };

    // Start the animation after a delay
    setTimeout(typeWriter, 1000);
  }

  // Scroll-Triggered Animations
  setupScrollAnimations() {
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('aos-animate');
          
          // Trigger counter animation if it's a stat element
          if (entry.target.classList.contains('stat')) {
            this.animateCounter(entry.target.querySelector('.stat__number'));
          }
        }
      });
    }, observerOptions);

    // Observe all animated elements
    const animatedElements = document.querySelectorAll('[data-aos]');
    animatedElements.forEach(el => {
      observer.observe(el);
    });

    // Observe stat elements
    const statElements = document.querySelectorAll('.stat');
    statElements.forEach(el => {
      observer.observe(el);
    });
  }

  // Counter Animations
  setupCounterAnimations() {
    // This will be triggered by the intersection observer
  }

  animateCounter(element) {
    if (!element || element.dataset.animated) return;
    
    const target = parseInt(element.dataset.count) || 0;
    const duration = 2000;
    const startTime = Date.now();
    const startValue = 0;

    const updateCounter = () => {
      const now = Date.now();
      const progress = Math.min((now - startTime) / duration, 1);
      
      // Easing function
      const easedProgress = 1 - Math.pow(1 - progress, 3);
      const currentValue = Math.floor(easedProgress * target);
      
      element.textContent = currentValue;
      
      if (progress < 1) {
        requestAnimationFrame(updateCounter);
      } else {
        element.textContent = target;
        element.dataset.animated = 'true';
      }
    };

    requestAnimationFrame(updateCounter);
  }

  // Form Handling
  setupFormHandling() {
    const contactForm = document.querySelector('.contact__form');
    if (!contactForm) return;

    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const formData = new FormData(contactForm);
      const submitBtn = contactForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.innerHTML;
      
      // Show loading state
      submitBtn.innerHTML = 'Sending... <span class="btn__icon">⏳</span>';
      submitBtn.disabled = true;

      try {
        // Simulate form submission (replace with actual endpoint)
        await this.simulateFormSubmission(formData);
        
        // Show success state
        submitBtn.innerHTML = 'Message Sent! <span class="btn__icon">✅</span>';
        contactForm.reset();
        
        // Show success notification
        this.showNotification('Message sent successfully!', 'success');
        
      } catch (error) {
        // Show error state
        submitBtn.innerHTML = 'Error Occurred <span class="btn__icon">❌</span>';
        this.showNotification('Failed to send message. Please try again.', 'error');
      } finally {
        // Reset button after delay
        setTimeout(() => {
          submitBtn.innerHTML = originalText;
          submitBtn.disabled = false;
        }, 3000);
      }
    });

    // Add input focus animations
    const inputs = contactForm.querySelectorAll('.form-control');
    inputs.forEach(input => {
      input.addEventListener('focus', (e) => {
        e.target.parentElement.classList.add('focused');
      });

      input.addEventListener('blur', (e) => {
        if (!e.target.value) {
          e.target.parentElement.classList.remove('focused');
        }
      });
    });
  }

  async simulateFormSubmission(formData) {
    // Simulate API call
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // Simulate success/failure
        Math.random() > 0.1 ? resolve() : reject();
      }, 2000);
    });
  }

  showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification--${type}`;
    notification.innerHTML = `
      <span class="notification__text">${message}</span>
      <button class="notification__close">&times;</button>
    `;

    // Add styles for notification
    notification.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 10000;
      padding: 1rem 2rem;
      border-radius: 10px;
      color: white;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 1rem;
      transform: translateX(100%);
      transition: transform 0.3s ease;
      background: ${type === 'success' ? 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' : 
                   type === 'error' ? 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' : 
                   'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'};
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
    `;

    document.body.appendChild(notification);

    // Animate in
    setTimeout(() => {
      notification.style.transform = 'translateX(0)';
    }, 100);

    // Handle close button
    const closeBtn = notification.querySelector('.notification__close');
    closeBtn.style.cssText = `
      background: none;
      border: none;
      color: white;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0;
      margin-left: 0.5rem;
    `;

    const closeNotification = () => {
      notification.style.transform = 'translateX(100%)';
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    };

    closeBtn.addEventListener('click', closeNotification);

    // Auto close after 5 seconds
    setTimeout(closeNotification, 5000);
  }

  // Smooth Scroll
  setupSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        
        const targetId = link.getAttribute('href').substring(1);
        const targetElement = document.getElementById(targetId);
        
        if (targetElement) {
          const offsetTop = targetElement.offsetTop - 80; // Account for fixed nav
          
          window.scrollTo({
            top: offsetTop,
            behavior: 'smooth'
          });
        }
      });
    });
  }

  // Parallax Effects
  setupParallax() {
    const parallaxElements = document.querySelectorAll('.hero__canvas, .hero__avatar');
    
    window.addEventListener('scroll', () => {
      const scrolled = window.pageYOffset;
      const rate = scrolled * -0.5;
      
      parallaxElements.forEach(element => {
        if (element.classList.contains('hero__canvas')) {
          element.style.transform = `translateY(${rate * 0.3}px)`;
        } else if (element.classList.contains('hero__avatar')) {
          element.style.transform = `translateY(${rate * 0.1}px)`;
        }
      });
    });
  }

  // Performance optimizations
  throttle(func, limit) {
    let inThrottle;
    return function() {
      const args = arguments;
      const context = this;
      if (!inThrottle) {
        func.apply(context, args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  }

  debounce(func, wait) {
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
}

// Advanced Features
class AdvancedEffects {
  constructor() {
    this.setupHoverEffects();
    this.setupScrollProgress();
    this.setupThemeToggle();
    this.setupLazyLoading();
  }

  setupHoverEffects() {
    // 3D hover effects for cards
    const cards = document.querySelectorAll('.glass-card');
    
    cards.forEach(card => {
      card.addEventListener('mouseenter', (e) => {
        card.style.willChange = 'transform';
      });

      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        
        const rotateX = (y - centerY) / 10;
        const rotateY = (centerX - x) / 10;
        
        card.style.transform = `
          perspective(1000px) 
          rotateX(${rotateX}deg) 
          rotateY(${rotateY}deg) 
          translateZ(20px)
        `;
      });

      card.addEventListener('mouseleave', () => {
        card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateZ(0)';
        card.style.willChange = 'auto';
      });
    });

    // Button ripple effect
    const buttons = document.querySelectorAll('.btn');
    
    buttons.forEach(button => {
      button.addEventListener('click', (e) => {
        const ripple = document.createElement('span');
        const rect = button.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;
        
        ripple.style.cssText = `
          position: absolute;
          width: ${size}px;
          height: ${size}px;
          left: ${x}px;
          top: ${y}px;
          background: rgba(255, 255, 255, 0.4);
          border-radius: 50%;
          transform: scale(0);
          animation: ripple 0.6s ease-out;
          pointer-events: none;
        `;
        
        button.style.position = 'relative';
        button.style.overflow = 'hidden';
        button.appendChild(ripple);
        
        setTimeout(() => {
          if (ripple.parentNode) {
            ripple.parentNode.removeChild(ripple);
          }
        }, 600);
      });
    });
  }

  setupScrollProgress() {
    const progressBar = document.createElement('div');
    progressBar.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 0%;
      height: 3px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      z-index: 10000;
      transition: width 0.1s ease;
    `;
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', () => {
      const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
      const scrollHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const progress = (scrollTop / scrollHeight) * 100;
      
      progressBar.style.width = `${progress}%`;
    });
  }

  setupThemeToggle() {
    // Auto theme detection and manual toggle could be added here
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
    
    prefersDark.addEventListener('change', (e) => {
      // Handle theme changes
      this.updateTheme(e.matches ? 'dark' : 'light');
    });
  }

  updateTheme(theme) {
    document.documentElement.setAttribute('data-color-scheme', theme);
    
    // Update particle colors if needed
    const canvas = document.getElementById('particles-canvas');
    if (canvas && window.portfolioApp) {
      // Re-initialize particles with new theme colors
    }
  }

  setupLazyLoading() {
    // Lazy load any heavy elements or images
    const lazyElements = document.querySelectorAll('[data-lazy]');
    
    const lazyObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const element = entry.target;
          // Load content
          element.classList.add('loaded');
          lazyObserver.unobserve(element);
        }
      });
    });

    lazyElements.forEach(el => lazyObserver.observe(el));
  }
}

// CSS animations for ripple effect
const style = document.createElement('style');
style.textContent = `
  @keyframes ripple {
    to {
      transform: scale(4);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
  window.portfolioApp = new PortfolioApp();
  window.advancedEffects = new AdvancedEffects();
});

// Handle page visibility for performance
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    // Pause heavy animations when page is not visible
  } else {
    // Resume animations when page becomes visible
  }
});

// Error handling
window.addEventListener('error', (e) => {
  console.error('Portfolio App Error:', e.error);
});

// Performance monitoring
if ('performance' in window) {
  window.addEventListener('load', () => {
    setTimeout(() => {
      const perfData = performance.getEntriesByType('navigation')[0];
      console.log('Page Load Performance:', {
        loadTime: perfData.loadEventEnd - perfData.loadEventStart,
        domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
        totalTime: perfData.loadEventEnd - perfData.fetchStart
      });
    }, 0);
  });
}