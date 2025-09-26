# Gemini API Recommendation Summarization

## Agreements & Decisions
- Add Google Gemini API integration to summarize individual recommendations into cohesive narrative
- Use Gemini Developer API instead of showing raw list of recommendations
- Maintain supportive tone and avoid specific medical claims in AI summary
- Show loading state during API call with fallback to original recommendations on error
- Replace individual recommendation cards with AI-generated summary in recommendations_section.dart

## Plan

### Phase 1: API Integration Setup
- [ ] Add `google_generative_ai` dependency to pubspec.yaml
- [ ] Configure API key storage (environment variables or secure storage)
- [ ] Create GeminiService class in services_and_utilities/

### Phase 2: Service Implementation
- [ ] Implement `summarizeRecommendations()` method
- [ ] Design prompt engineering for consistent, helpful summaries
- [ ] Configure model settings (gemini-pro, temperature ~0.7)
- [ ] Add input validation and response parsing

### Phase 3: UI Integration
- [ ] Update recommendations_section.dart to call Gemini API
- [ ] Add animated kettlebell thinking loading state while API processes
- [ ] Replace recommendation cards with AI summary display
- [ ] Style summary text appropriately
- [ ] Create ThinkingKettlebellWidget with animation (rotation, pulsing, or thinking bubbles)

### Phase 4: Error Handling & Polish
- [ ] Implement graceful error handling (network, quota, invalid responses)
- [ ] Add fallback to original recommendation list on failure
- [ ] Test with various recommendation combinations
- [ ] Performance optimization and caching if needed

## Technical Implementation

### Gemini Service Structure
```dart
class GeminiService {
  static Future<String> summarizeRecommendations({
    required List<String> recommendations,
    required Map<String, dynamic> userContext,
  })

  // Prompt engineering for consistent outputs
  // Error handling and fallbacks
  // Response validation
}
```

### UI Flow
1. recommendations_section calculates recommendations (existing)
2. Pass recommendations array to GeminiService
3. Show loading indicator
4. Display AI summary or fallback to original list
5. Handle errors gracefully

### Prompt Design
Transform individual recommendations into narrative format:
- "Based on your assessment, here are your key priorities..."
- Combine related recommendations
- Maintain encouraging, supportive tone
- Avoid specific medical percentages or claims
- Include personalization (age, fitness level context)

## Notes
- API calls will add latency - need good loading UX
- Consider caching responses for identical recommendation sets
- Monitor API costs and usage quotas
- Test with edge cases (no recommendations, API failures)
- Maintain fallback path to ensure recommendations always display

## Success Criteria
- [ ] AI summary replaces individual recommendation cards
- [ ] Loading state provides good user experience
- [ ] Error handling ensures recommendations always shown
- [ ] Summary tone matches app voice and avoids medical claims
- [ ] Performance acceptable for real-time use