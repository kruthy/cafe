/**
 * @author      Dennis W. Gichangi <dennis@openbaraza.org>
 * @version     2011.0329
 * @since       1.6
 * website		www.openbaraza.org
 * The contents of this file are subject to the GNU Lesser General Public License
 * Version 3.0 ; you may use this file in compliance with the License.
 */
package org.baraza.utils;

import java.util.Map;
import java.util.HashMap;
import java.util.Enumeration;
import java.util.logging.Logger;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.exceptions.JWTCreationException;
import com.auth0.jwt.exceptions.JWTVerificationException;

import javax.servlet.http.HttpServletRequest;

public class BWebUtils {
	static Logger log = Logger.getLogger(BWebUtils.class.getName());

	public static void showHeaders(HttpServletRequest request) {
		System.out.println("HEADERS ------- ");
		Enumeration<String> headerNames = request.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String headerName = headerNames.nextElement();
			System.out.println(headerName);
			request.getHeader(headerName);
			Enumeration<String> headers = request.getHeaders(headerName);
			while (headers.hasMoreElements()) {
				String headerValue = headers.nextElement();
				System.out.println("\t" + headerValue);
			}
		}
		System.out.print("\n");
	}

	public static void showParameters(HttpServletRequest request) {
		System.out.println("PARAMETERS ------- ");
		Enumeration en = request.getParameterNames();
        while (en.hasMoreElements()) {
			String paramName = (String)en.nextElement();
			System.out.println(paramName + " : " + request.getParameter(paramName));
		}
		System.out.print("\n");
	}
	
	public static String createToken(String userId) {
		String token = null;
		try {
			Algorithm algorithm = Algorithm.HMAC256("secret");
			token = JWT.create().withIssuer("auth0").withSubject(userId).sign(algorithm);
		} catch (UnsupportedEncodingException ex){
			log.severe("UnsupportedEncodingException : " + ex);
		} catch (JWTCreationException ex){
			log.severe("JWTCreationException : " + ex);
		}
		
		return token;
	}
	
	public static String decodeToken(String token) {
		String payLoad = null;
		try {
			Algorithm algorithm = Algorithm.HMAC256("secret");
			JWTVerifier verifier = JWT.require(algorithm).withIssuer("auth0").build(); 
			DecodedJWT jwt = verifier.verify(token);
			payLoad = jwt.getSubject();
		} catch (UnsupportedEncodingException ex){
			log.severe("UnsupportedEncodingException : " + ex);
		} catch (JWTVerificationException ex){
			log.severe("JWTVerificationException : " + ex);
		}
		return payLoad;
	}
	
	public static String requestBody(HttpServletRequest request) {
		StringBuffer jb = new StringBuffer();
		String line = null;
		try {
			BufferedReader reader = request.getReader();
			while ((line = reader.readLine()) != null) jb.append(line);
		} catch (IOException ex) {
			log.severe("JWTVerificationException : " + ex);
		}
		return jb.toString();
	}
	
	public static int getFieldType(String fieldTypeName) {
		int type = 0;
		if(fieldTypeName == null) type = 0;
		else if(fieldTypeName.equals("TEXTFIELD")) type = 0;
		else if(fieldTypeName.equals("TEXTAREA")) type = 1;
		else if(fieldTypeName.equals("CHECKBOX")) type = 2;
		else if(fieldTypeName.equals("TEXTTIME")) type = 3;
		else if(fieldTypeName.equals("TEXTDATE")) type = 4;
		else if(fieldTypeName.equals("TEXTTIMESTAMP")) type = 5;
		else if(fieldTypeName.equals("SPINTIME")) type = 6;
		else if(fieldTypeName.equals("SPINDATE")) type = 7;
		else if(fieldTypeName.equals("SPINTIMESTAMP")) type = 8;
		else if(fieldTypeName.equals("TEXTDECIMAL")) type = 9;
		else if(fieldTypeName.equals("COMBOLIST")) type = 10;
		else if(fieldTypeName.equals("COMBOBOX")) type = 11;
		else if(fieldTypeName.equals("GRIDBOX")) type = 12;
		else if(fieldTypeName.equals("DEFAULT")) type = 13;
		else if(fieldTypeName.equals("EDITOR")) type = 14;
		else if(fieldTypeName.equals("FUNCTION")) type = 15;
		else if(fieldTypeName.equals("USERFIELD")) type = 16;
		else if(fieldTypeName.equals("USERNAME")) type = 17;
		else if(fieldTypeName.equals("PICTURE")) type = 18;
		return type;
	}

}
