# **Google Groupp Link** Plugin

**Plugin Summary**

This plugin will search `raw_email` of the first post of new topics in categories with `mailinglist_mirror` set for a Google Group link and add it to a `TopicCustomField` that is added to the `topic_view` serializer. It adds a link to the `topic-category` plugin outlet like

     See original message on <a href=google-group-url>Google Groups</a>

"See original message on" can be customized in the `link_intro` site setting.

'Google Groups' can be customized in the `link_target` site setting.

To process already existing topics, you can do this in rails:

```
t=Topic.last;
t.google_group_link_ensure_consistency
```
