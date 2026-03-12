## Design Thinking Process

The UI design for PetSaathi followed the five stages of design thinking.

Empathize  
Pet owners need a quick way to book trustworthy walkers and monitor pet care.

Define  
The interface must allow users to discover caregivers quickly, manage bookings, and communicate easily.

Ideate  
Wireframes were created focusing on minimal navigation, card-based layouts, and clear booking actions.

Prototype  
A Figma prototype was created with four primary screens:
Login, Owner Dashboard, Walker Dashboard, and Profile.

Test  
The design is structured so it can be directly translated into Flutter widgets while remaining responsive across different screen sizes.

## Responsive Design Approach

The Flutter implementation will use responsive layout techniques to ensure usability across devices.

Key techniques:

- MediaQuery to adapt layout based on screen width
- Flexible and Expanded widgets to prevent layout overflow
- ListView for scrollable caregiver cards
- Adaptive spacing for small and large screens

For example:

Small screens → Column layout  
Large screens → Grid or Row layout