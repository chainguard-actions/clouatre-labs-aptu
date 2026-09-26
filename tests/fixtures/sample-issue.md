# Feature Request: Add dark mode support

## Summary

Add dark mode support to the application UI.

## Motivation

Many users prefer dark mode for reduced eye strain, especially when working at night.
Dark mode is now a standard feature expected in modern applications.

## Proposed Solution

Implement a dark mode toggle in the settings panel that:
- Switches the color scheme to dark colors
- Persists the user preference in local storage
- Respects the system-level dark mode preference via `prefers-color-scheme`

## Acceptance Criteria

- [ ] Dark mode toggle is accessible from the settings panel
- [ ] User preference is persisted across sessions
- [ ] System preference is respected by default
- [ ] All UI components render correctly in dark mode

## Additional Context

This feature has been requested by multiple users in issue #42 and #57.
