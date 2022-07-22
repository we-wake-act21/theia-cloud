/********************************************************************************
 * Copyright (C) 2022 EclipseSource and others.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the Eclipse
 * Public License v. 2.0 are satisfied: GNU General Public License, version 2
 * with the GNU Classpath Exception which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 ********************************************************************************/
package org.eclipse.theia.cloud.common.k8s.resource;

import java.time.Instant;

public final class WorkspaceUtil {
    private static final String SESSION_SUFFIX = "-session";
    private static final String STORAGE_SUFFIX = "-pvc";

    private WorkspaceUtil() {
	// util
    }

    public static String generateWorkspaceName(String user, String appDefinitionName) {
	return ("ws-" + appDefinitionName + "-" + SessionUtil.validUserName(user) + "-" + Instant.now().toEpochMilli())
		.toLowerCase();
    }

    public static String getSessionName(String workspaceName) {
	return workspaceName + SESSION_SUFFIX;
    }

    public static String getStorageName(String workspaceName) {
	return workspaceName + STORAGE_SUFFIX;
    }

    public static String getWorkspaceNameFromSession(String sessionName) {
	return sessionName.endsWith(SESSION_SUFFIX)
		? sessionName.substring(sessionName.length() - SESSION_SUFFIX.length())
		: sessionName;
    }

    public static String getWorkspaceNameFromStorage(String pvcName) {
	return pvcName.endsWith(STORAGE_SUFFIX) ? pvcName.substring(pvcName.length() - STORAGE_SUFFIX.length())
		: pvcName;
    }

    public static String generateWorkspaceLabel(String user, String appDefinitionName) {
	return appDefinitionName + " of " + user;
    }

}
