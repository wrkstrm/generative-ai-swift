# Agency Updates

This document tracks agency updates and defines the standard format for recording them.

## Update Format

Each update is documented with a YAML metadata block immediately followed by the update text. The
metadata captures key fields and attaches context to the update.

Metadata block structure:

```yaml
id: <unique identifier>
author: <name>
date: <YYYY-MM-DD>
status: <planned|in-progress|complete>
```

The metadata block must directly precede the associated update text with no blank lines in between.

## Example

```yaml
id: 2024-06-12
author: Project Manager
date: 2024-06-12
status: complete
```

Defined a unified standard for agency updates with YAML metadata blocks.

```yaml
id: 2025-09-02-model-ownership
author: ChatGPT
date: 2025-09-02
status: complete
```
Shifted model loading to the screen view model and allowed each chat to select its own model.

```yaml
id: 2025-09-02-model-loading-guard
author: ChatGPT
date: 2025-09-02
status: complete
```
Guarded new chat creation until models load and centralized logging across GenChatUI.

```yaml
id: 2025-09-02-chat-model-picker
author: ChatGPT
date: 2025-09-02
status: complete
```
Introduced a chat-level model picker with confirmation before changing models.
