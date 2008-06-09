<%
/**
 * Copyright (c) 2000-2008 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/json_init.jsp" %>

<%
if (!themeDisplay.isSignedIn()) {
	return;
}

// Status

StatusLocalServiceUtil.updateStatus(themeDisplay.getUserId());

// Buddies

long buddiesModifiedDate = System.currentTimeMillis() - Time.MINUTE;

List<Object[]> buddies = StatusLocalServiceUtil.getSocialStatuses(themeDisplay.getUserId(), SocialRelationConstants.TYPE_BI_FRIEND, buddiesModifiedDate, 0, SearchContainer.DEFAULT_DELTA);

JSONArray buddiesJSON = new JSONArray();

for (Object[] buddy : buddies) {
	long userId = (Long)buddy[0];
	String firstName = (String)buddy[1];
	String middleName = (String)buddy[2];
	String lastName = (String)buddy[3];

	String fullName = ContactConstants.getFullName(firstName, middleName, lastName);

	if (userId == themeDisplay.getUserId()) {
		continue;
	}

	JSONObject curUserJSON = new JSONObject();

	JSONUtil.put(curUserJSON, "userId", userId);
	JSONUtil.put(curUserJSON, "userName", fullName);

	buddiesJSON.put(curUserJSON);
}

// Entries

long entriesCreateDate = ParamUtil.getLong(request, "entriesCreateDate");

if (entriesCreateDate == 0) {
	entriesCreateDate = System.currentTimeMillis() - Time.MINUTE;
}

List<Entry> entries = EntryLocalServiceUtil.getNewEntries(themeDisplay.getUserId(), entriesCreateDate, 0, SearchContainer.DEFAULT_DELTA);

Collections.reverse(entries);

JSONArray entriesJSON = new JSONArray();

for (Entry entry : entries) {
	JSONObject entryJSON = new JSONObject();

	JSONUtil.put(entryJSON, "createDate", entry.getCreateDate());
	JSONUtil.put(entryJSON, "fromUserId", entry.getFromUserId());
	JSONUtil.put(entryJSON, "toUserId", entry.getToUserId());
	JSONUtil.put(entryJSON, "content", entry.getContent());

	entriesJSON.put(entryJSON);
}

// JSON

JSONObject jsonObj = new JSONObject();

JSONUtil.put(jsonObj, "buddies", buddiesJSON);
JSONUtil.put(jsonObj, "entries", entriesJSON);
%>

<%= jsonObj %>