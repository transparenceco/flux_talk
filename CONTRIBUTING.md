# Development Guide

## Development Setup

### Prerequisites
- Swift 6.0+ for backend development
- Node.js 18+ for web frontend
- Xcode 15+ for iOS development (optional)
- Git for version control

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/your-org/flux_talk.git
cd flux_talk

# Run automated setup
./setup.sh
```

## Development Workflow

### Backend Development

```bash
cd backend

# Build the project
swift build

# Run in development mode
swift run

# Run with custom port (edit code or use environment variable)
# The server runs on 0.0.0.0:8080 by default
```

#### Adding New Endpoints

1. Create a new controller in `Sources/FluxTalkBackend/Controllers/`
2. Register the controller in `FluxTalkBackend.swift` in the `routes()` function
3. Add DTOs in `Sources/FluxTalkBackend/DTOs/` if needed
4. Update API.md with the new endpoint documentation

Example:
```swift
// In Controllers/ExampleController.swift
import Vapor

struct ExampleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let example = routes.grouped("api", "example")
        example.get(use: index)
    }
    
    func index(req: Request) async throws -> String {
        return "Hello from Example!"
    }
}

// In FluxTalkBackend.swift
try app.register(collection: ExampleController())
```

#### Database Migrations

Add a new migration:
```swift
// In Migrations/CreateNewTable.swift
import Fluent

struct CreateNewTable: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("new_table")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("new_table").delete()
    }
}

// Register in configure()
app.migrations.add(CreateNewTable())
```

### Web Frontend Development

```bash
cd web-app

# Install dependencies
npm install

# Run development server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

#### Project Structure
```
web-app/
├── src/
│   ├── components/      # React components
│   │   ├── App.jsx      # Main app component
│   │   └── SettingsModal.jsx
│   ├── services/        # API service layer
│   │   └── api.js       # Backend API calls
│   └── styles/          # CSS styles
│       └── App.css
├── public/              # Static assets
├── index.html           # HTML template
└── vite.config.js       # Vite configuration
```

#### Adding New Features

1. Create a new component in `src/components/`
2. Add API calls in `src/services/api.js`
3. Update styles in `src/styles/App.css`
4. Import and use in `App.jsx`

### iOS App Development

The iOS app is a Swift Package that can be opened in Xcode or built from command line.

```bash
cd ios-app/FluxTalk

# Build the package
swift build

# Or open in Xcode
open Package.swift
```

#### Project Structure
```
ios-app/FluxTalk/FluxTalk/
├── Models/              # Data models
├── Views/               # SwiftUI views
├── ViewModels/          # View models (MVVM)
├── Services/            # API and business logic
└── FluxTalkApp.swift    # App entry point
```

## Code Style

### Swift (Backend & iOS)
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use meaningful variable and function names

### JavaScript/React (Web)
- Use ES6+ features
- Use functional components with hooks
- Use 2 spaces for indentation
- Follow [Airbnb React Style Guide](https://github.com/airbnb/javascript/tree/master/react)

## Testing

### Backend Testing
```bash
cd backend
# Run tests (when tests are added)
swift test
```

### API Testing
```bash
# Start the backend first
cd backend && swift run &

# In another terminal, run the test script
./test-api.sh
```

### Web Frontend Testing
```bash
cd web-app
# Add tests using Vitest or Jest
npm test
```

## Debugging

### Backend Debugging
- Use `print()` statements for simple debugging
- Use Xcode debugger for more complex issues
- Check logs in terminal output

### Web Frontend Debugging
- Use browser DevTools (F12)
- Check Network tab for API calls
- Use React DevTools extension

### iOS Debugging
- Use Xcode debugger
- Add breakpoints in code
- Check console logs in Xcode

## Common Issues

### Backend won't start
**Issue:** Port 8080 already in use
**Solution:**
```bash
# Find and kill process on port 8080
lsof -ti:8080 | xargs kill -9
```

**Issue:** SQLite database locked
**Solution:**
```bash
# Remove database file and restart
rm backend/flux_talk.sqlite
```

### Web app can't connect to backend
**Issue:** CORS errors in browser console
**Solution:** Check that backend CORS is configured correctly in `configure()` function

**Issue:** Network errors
**Solution:** Verify backend is running and `VITE_API_URL` in `.env` is correct

### iOS app can't connect
**Issue:** Connection refused
**Solution:**
1. Check that backend is running
2. Verify server URL in app settings matches your computer's IP
3. Ensure both devices are on same network
4. Check firewall settings

## Performance Tips

### Backend
- Use async/await for all I/O operations
- Implement caching for frequently accessed data
- Optimize database queries
- Consider adding request rate limiting

### Web Frontend
- Use React.memo() for expensive components
- Implement virtual scrolling for long message lists
- Lazy load images and components
- Minimize bundle size

## Security Considerations

### API Keys
- Never commit `.env` files
- Use environment variables for sensitive data
- Rotate API keys regularly

### Data Validation
- Validate all user input on backend
- Sanitize data before storing in database
- Use parameterized queries to prevent SQL injection

### Network Security
- Use HTTPS in production
- Implement authentication (not in MVP)
- Add rate limiting to prevent abuse

## Contributing

### Before Submitting PR
1. Ensure code builds without warnings
2. Test your changes thoroughly
3. Update documentation if needed
4. Follow code style guidelines
5. Add tests for new features

### PR Process
1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit PR with clear description
5. Address review comments

## Resources

### Backend (Vapor)
- [Vapor Documentation](https://docs.vapor.codes/)
- [Fluent Documentation](https://docs.vapor.codes/fluent/overview/)
- [Swift.org](https://swift.org/)

### Web Frontend
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [MDN Web Docs](https://developer.mozilla.org/)

### iOS
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### AI Integration
- [LM Studio](https://lmstudio.ai/)
- [OpenAI API](https://platform.openai.com/docs/)
- [Grok API](https://console.x.ai/)
- [Chroma Documentation](https://docs.trychroma.com/)
