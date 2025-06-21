# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a Rails 8.0.2 application for internal use only, built with modern Rails conventions and the Hotwire stack.

## Technology Stack
- **Rails**: 8.0.2 with Ruby 3.4.3
- **Database**: PostgreSQL with Solid gems (Solid Cache, Queue, Cable)
- **Frontend**: Tailwind CSS + DaisyUI components, Hotwire (Turbo + Stimulus)
- **Authentication**: Rails 8 built-in authentication (not Devise)
- **Testing**: RSpec Rails with Factory Bot, Faker, Capybara
- **Deployment**: Docker + Kamal

## Common Development Commands

### Development Server
```bash
# Start development server with CSS watching
bin/dev

# Or individually:
bin/rails server
bin/rails tailwindcss:watch
```

### Database
```bash
# Setup database
bin/rails db:create db:migrate db:seed

# Reset database
bin/rails db:reset

# Generate new migration
bin/rails generate migration MigrationName
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test
bundle exec rspec spec/models/user_spec.rb:10
```

### Code Quality
```bash
# Security audit
bundle exec brakeman

# Style check
bundle exec rubocop

# Auto-fix style issues
bundle exec rubocop -a
```

### Assets
```bash
# Precompile assets
bin/rails assets:precompile

# Clean compiled assets
bin/rails assets:clean
```

## Authentication Architecture

### Models
- `User`: Email-based authentication with `has_secure_password`
- `Session`: Tracks user sessions with IP address and user agent
- `Current`: ActiveSupport::CurrentAttributes for request-scoped context

### Key Features
- Email normalization and validation
- Rate limiting (10 attempts per 3 minutes)
- Secure session cookies with `httponly` and `same_site: :lax`
- IP address and user agent tracking
- Built-in password reset functionality

### Authentication Flow
- Root path redirects to login (`sessions#new`)
- All pages require authentication except login page
- Sessions are database-backed, not token-based
- Logout button appears in navbar when authenticated

## Application Structure

### Controllers
- `ApplicationController`: Includes Authentication concern
- `SessionsController`: Login/logout with rate limiting
- `PasswordsController`: Password reset functionality

### Authentication Helpers
- `authenticated?`: Check if user is signed in
- `require_authentication`: Before action for protected routes
- `allow_unauthenticated_access`: Skip authentication for specific actions

### Database Schema
- Users: `email_address` (unique), `password_digest`
- Sessions: `user_id`, `ip_address`, `user_agent`
- Uses PostgreSQL with multiple database configuration

## Frontend Architecture

### CSS Framework
- Tailwind CSS for utility classes
- DaisyUI for pre-built components
- Light theme configured by default

### JavaScript
- Hotwire (Turbo Rails + Stimulus) for SPA-like experience
- Importmaps for modern JavaScript without bundling
- Minimal JavaScript approach

### Layout Structure
- `application.html.erb`: Main layout with responsive navbar
- Conditional logout button based on authentication state
- Flash message support for alerts and notices

## Development Guidelines

### Authentication Requirements
- This application is internal use only
- Every page except login page needs authentication
- Use Rails built-in authentication, not external gems like Devise

### Code Generation
- Use `bin/rails generate authentication` for auth scaffolding
- RSpec for testing (not default Rails testing)
- Follow Rails 8 conventions and patterns

### Security Practices
- CSRF protection enabled
- Content Security Policy configured
- Modern browser requirements enforced
- Database-backed sessions with secure cookies

## Deployment
- Containerized with Docker
- Kamal for deployment orchestration
- Thruster for production HTTP acceleration
- Health check endpoint at `/up`