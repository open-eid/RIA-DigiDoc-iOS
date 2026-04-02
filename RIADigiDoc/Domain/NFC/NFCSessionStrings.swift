/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

public struct NFCSessionStrings: Sendable {
    let initialMessage: String
    let step1Message: String
    let step2Message: String
    let step3Message: String
    let step4Message: String
    let successMessage: String
    let canErrorMessage: String
    let pinWrongMultipleErrorMessage: String
    let pinWrongErrorMessage: String
    let pinBlockedErrorMessage: String
    let wrongCardErrorMessage: String
    let technicalErrorMessage: String
    let sessionErrorMessage: String
    let ocspTimeslotErrorMessage: String
    let certificateRevokedErrorMessage: String
    let tooManyRequestsErrorMessage: String
    let networkErrorMessage: String
    let sslErrorMessage: String
}
