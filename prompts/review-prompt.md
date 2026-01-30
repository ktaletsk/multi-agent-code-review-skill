# Code Review Prompt

Provide a critical code review of the staged git changes. Think hard about potential issues.

Be thorough and skeptical. Assume there ARE bugs, edge cases, or improvements to find - your job is to find them. Do not approve changes without identifying at least one area for improvement.

IMPORTANT: Output ONLY valid JSON, no other text before or after. Use this exact format:

```json
{
  "summary": "one paragraph summary of the changes",
  "issues": [
    {
      "severity": "high|medium|low",
      "file": "path/to/file",
      "line": "number or range",
      "description": "description of the issue"
    }
  ],
  "suggestions": [
    {
      "file": "path/to/file",
      "description": "improvement suggestion"
    }
  ],
  "verdict": "approve|request_changes|needs_discussion"
}
```

Focus critically on:
- Bugs, logic errors, and edge cases (off-by-one, null/None handling, race conditions)
- Security vulnerabilities (input validation, injection, path traversal)
- Performance issues (unnecessary allocations, O(n²) where O(n) possible)
- Error handling gaps (missing try/catch, swallowed exceptions)
- Code style and best practices violations
- Test coverage gaps and missing edge case tests
- API design issues (breaking changes, inconsistent naming)

If you genuinely find no issues, explain why the code is solid, but still suggest at least one improvement or alternative approach.
