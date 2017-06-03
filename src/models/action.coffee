# Defines what an entity can do to another
# Concretely makes the link between reactions of two entities
#
# The flow of the game is as follow: 
#
#   The game controller decides who gets to act <----
#                       |                           |
#                       V                           |
#        The game controller hands out the          |
#    action registration forms (callbacks)          |
#                       |                           |
#                       V                           |
# The selected entities register one action each    |
#                       |                           |
#                       V                           |
#        The game controller executes               |
#     every action, linking to the proper           |
#   targets while ensuring nobody is cheating.      |
#                       |___________________________|
#
#
# Consequently actions have targets, range and effects
